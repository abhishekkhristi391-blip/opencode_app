import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import 'app_scope.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';

/// Renders pending permission requests and clarifying questions on top of
/// whatever screen is open, so a tool approval never gets lost behind a route.
class PromptOverlay extends StatelessWidget {
  const PromptOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    if (scope == null) return const SizedBox.shrink();
    final store = scope.notifier!;
    final q = store.questions.isNotEmpty ? store.questions.first : null;
    final p = store.permissions.isNotEmpty ? store.permissions.first : null;
    if (q == null && p == null) return const SizedBox.shrink();
    return IgnorePointer(
      ignoring: false,
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: q != null ? _QuestionCard(q) : _PermissionCard(p!),
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final PermissionReq p;
  const _PermissionCard(this.p);

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final detail = p.detail;

    return OCCard(
      padding: const EdgeInsets.all(OCSpace.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const OCIconTile(
                icon: Icons.shield_outlined,
                accent: OCAccent.purple,
                size: 36,
                iconSize: 20,
              ),
              const SizedBox(width: OCSpace.md),
              Expanded(
                child: Text(
                  'Permission chahiye',
                  style: OCTypography.h2.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: OCSpace.sm),
          Text(
            'opencode "${p.title}" karne ja raha hai.',
            style: OCTypography.caption,
          ),
          if (detail.isNotEmpty) ...[
            const SizedBox(height: OCSpace.md),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 220),
              padding: const EdgeInsets.all(OCSpace.md),
              decoration: BoxDecoration(
                color: OCColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(OCRadius.inner),
              ),
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    detail,
                    style: OCTypography.mono(size: 11.5),
                  ),
                ),
              ),
            ),
          ],
          if (p.always.isNotEmpty) ...[
            const SizedBox(height: OCSpace.md),
            Text(
              'Server is rules suggest kar raha hai: ${p.always.join(', ')}',
              style: OCTypography.micro,
            ),
          ],
          const SizedBox(height: OCSpace.lg),
          Row(
            children: [
              Expanded(
                child: OCButton(
                  label: 'Deny',
                  variant: OCButtonVariant.ghostOutline,
                  onPressed: () => store.answerPermission(p, 'reject'),
                ),
              ),
              const SizedBox(width: OCSpace.sm),
              Expanded(
                child: OCButton(
                  label: 'Always',
                  variant: OCButtonVariant.secondaryPill,
                  onPressed: () => store.answerPermission(p, 'always'),
                ),
              ),
              const SizedBox(width: OCSpace.sm),
              Expanded(
                child: OCButton(
                  label: 'Allow',
                  variant: OCButtonVariant.primaryBlack,
                  onPressed: () => store.answerPermission(p, 'once'),
                ),
              ),
            ],
          ),
          const SizedBox(height: OCSpace.sm),
          Center(
            child: Text(
              'Baaki ${store.permissions.length - 1} request(s) pending',
              style: OCTypography.micro,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final QuestionReq q;
  const _QuestionCard(this.q);

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late Map<int, Set<String>> picks = {
    for (var i = 0; i < widget.q.questions.length; i++) i: <String>{},
  };
  final custom = <int, TextEditingController>{};

  @override
  void dispose() {
    for (final c in custom.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggle(int qi, String label, bool multiple) {
    setState(() {
      final s = picks.putIfAbsent(qi, () => <String>{});
      if (!multiple) {
        s
          ..clear()
          ..add(label);
      } else if (s.contains(label)) {
        s.remove(label);
      } else {
        s.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return OCCard(
      padding: const EdgeInsets.all(OCSpace.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const OCIconTile(
                icon: Icons.help_outline,
                accent: OCAccent.orange,
                size: 36,
                iconSize: 20,
              ),
              const SizedBox(width: OCSpace.md),
              const Expanded(
                child: Text(
                  'Agent ne sawal pucha',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: OCColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: OCSpace.md),
          for (var i = 0; i < widget.q.questions.length; i++) ...[
            if (i > 0) const Divider(height: OCSpace.xxl),
            _question(context, widget.q.questions[i], i),
          ],
          const SizedBox(height: OCSpace.lg),
          Row(
            children: [
              Expanded(
                child: OCButton(
                  label: 'Skip',
                  variant: OCButtonVariant.ghostOutline,
                  onPressed: () => store.rejectQuestion(widget.q),
                ),
              ),
              const SizedBox(width: OCSpace.sm),
              Expanded(
                flex: 2,
                child: OCButton(
                  label: 'Bhejo',
                  variant: OCButtonVariant.primaryBlack,
                  onPressed: () {
                    final answers = <List<String>>[];
                    for (var i = 0; i < widget.q.questions.length; i++) {
                      final s = picks[i] ?? <String>{};
                      if (widget.q.questions[i].custom) {
                        final t = custom[i]?.text.trim();
                        if (t != null && t.isNotEmpty) s.add(t);
                      }
                      answers.add(s.toList());
                    }
                    store.answerQuestion(widget.q, answers);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _question(BuildContext context, QuestionItem item, int qi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.header.isNotEmpty)
          Text(
            item.header.toUpperCase(),
            style: OCTypography.micro.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        const SizedBox(height: OCSpace.xs),
        Text(
          item.question,
          style: OCTypography.body.copyWith(color: OCColors.textPrimary),
        ),
        if (item.multiple)
          Padding(
            padding: const EdgeInsets.only(top: OCSpace.xxs),
            child: Text(
              'Multiple select ho sakta hai',
              style: OCTypography.micro,
            ),
          ),
        const SizedBox(height: OCSpace.sm),
        for (final o in item.options)
          Container(
            margin: const EdgeInsets.only(bottom: OCSpace.xs),
            decoration: BoxDecoration(
              color: (picks[qi] ?? const {}).contains(o.label)
                  ? OCColors.orangeTint
                  : OCColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(OCRadius.inner),
            ),
            child: CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: (picks[qi] ?? const {}).contains(o.label),
              title: Text(
                o.label,
                style: OCTypography.caption.copyWith(
                  color: OCColors.textPrimary,
                ),
              ),
              subtitle: o.description.isEmpty
                  ? null
                  : Text(o.description, style: OCTypography.micro),
              onChanged: (_) => _toggle(qi, o.label, item.multiple),
            ),
          ),
        if (item.custom)
          Padding(
            padding: const EdgeInsets.only(top: OCSpace.sm),
            child: TextField(
              controller: custom.putIfAbsent(qi, TextEditingController.new),
              decoration: InputDecoration(
                hintText: 'Apna answer likho…',
                hintStyle: OCTypography.caption,
                isDense: true,
                filled: true,
                fillColor: OCColors.surfaceSubtle,
                prefixIcon: const Icon(
                  Icons.edit_outlined,
                  size: 17,
                  color: OCColors.textTertiary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OCRadius.inner),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OCRadius.inner),
                  borderSide: BorderSide.none,
                ),
              ),
              style: OCTypography.caption.copyWith(color: OCColors.textPrimary),
            ),
          ),
      ],
    );
  }
}

/// Small "copy" affordance used by the share card.
class ShareCard extends StatelessWidget {
  final String url;
  const ShareCard({super.key, required this.url});

  @override
  Widget build(BuildContext context) => OCCard(
    padding: EdgeInsets.zero,
    child: ListTile(
      leading: const OCIconTile(
        icon: Icons.link,
        accent: OCAccent.blue,
        size: 36,
      ),
      title: Text('Share link', style: OCTypography.h3.copyWith(fontSize: 15)),
      subtitle: Text(
        url,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: OCTypography.mono(size: 11.5, color: OCColors.textSecondary),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.copy, color: OCColors.textSecondary),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: url));
          showSnack(context, 'Link copy ho gaya');
        },
      ),
    ),
  );
}
