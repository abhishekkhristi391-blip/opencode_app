import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/models.dart';
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
              child: q != null
                  ? _QuestionCard(q)
                  : _PermissionCard(p!),
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
    final cs = Theme.of(context).colorScheme;
    final store = AppScope.of(context);
    final detail = p.detail;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_outlined, color: cs.primary, size: 20),
                const SizedBox(width: 9),
                Expanded(
                  child: Text('Permission chahiye', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('opencode "${p.title}" karne ja raha hai.',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
            if (detail.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 220),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(detail,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, height: 1.45)),
                  ),
                ),
              ),
            ],
            if (p.always.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Server is rules suggest kar raha hai: ${p.always.join(', ')}',
                  style: TextStyle(fontSize: 11, color: cs.outline)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: cs.error),
                    onPressed: () => store.answerPermission(p, 'reject'),
                    child: const Text('Deny', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => store.answerPermission(p, 'always'),
                    child: const Text('Always', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => store.answerPermission(p, 'once'),
                    child: const Text('Allow', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Center(
              child: Text('Baaki ${store.permissions.length - 1} request(s) pending',
                  style: TextStyle(fontSize: 10.5, color: cs.outline)),
            ),
          ],
        ),
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
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.help_outline, color: cs.primary, size: 20),
              const SizedBox(width: 9),
              const Expanded(
                child: Text('Agent ne sawal pucha', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 10),
            for (var i = 0; i < widget.q.questions.length; i++) ...[
              if (i > 0) const Divider(height: 22),
              _question(context, widget.q.questions[i], i),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: cs.error),
                    onPressed: () => store.rejectQuestion(widget.q),
                    child: const Text('Skip', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: FilledButton(
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
                    child: const Text('Bhejo', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _question(BuildContext context, QuestionItem item, int qi) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.header.isNotEmpty)
          Text(item.header.toUpperCase(),
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: cs.outline, letterSpacing: 0.6)),
        const SizedBox(height: 4),
        Text(item.question, style: const TextStyle(fontSize: 14)),
        if (item.multiple)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text('Multiple select ho sakta hai', style: TextStyle(fontSize: 10.5, color: cs.outline)),
          ),
        const SizedBox(height: 8),
        for (final o in item.options)
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: (picks[qi] ?? const {}).contains(o.label),
            title: Text(o.label, style: const TextStyle(fontSize: 13)),
            subtitle: o.description.isEmpty
                ? null
                : Text(o.description, style: const TextStyle(fontSize: 11)),
            onChanged: (_) => _toggle(qi, o.label, item.multiple),
          ),
        if (item.custom)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: TextField(
              controller: custom.putIfAbsent(qi, TextEditingController.new),
              decoration: const InputDecoration(
                hintText: 'Apna answer likho…',
                isDense: true,
                prefixIcon: Icon(Icons.edit_outlined, size: 17),
              ),
              style: const TextStyle(fontSize: 13),
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
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.link),
          title: const Text('Share link'),
          subtitle: Text(url, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5)),
          trailing: IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              showSnack(context, 'Link copy ho gaya');
            },
          ),
        ),
      );
}
