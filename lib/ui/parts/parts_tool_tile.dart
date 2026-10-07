part of '../parts.dart';

class _Collapsible extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget child;

  /// One slim line instead of a card. For blocks that appear on every step of
  /// a turn (the model's reasoning) and must not take over the transcript.
  final bool compact;
  const _Collapsible({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.color,
    this.compact = false,
  });

  @override
  State<_Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<_Collapsible> {
  bool open = false;

  /// `[icon] Thought for 3s  v`: ~32dp tall, no card, no shadow. The body only
  /// takes space once the user opens it.
  Widget _buildCompact(BuildContext context) {
    final t = context.oc;
    final label = widget.subtitle.isNotEmpty ? widget.subtitle : widget.title;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => open = !open),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 32),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 2),
                    Icon(widget.icon, size: 15, color: widget.color),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OCTypography.micro.copyWith(color: widget.color),
                      ),
                    ),
                    Icon(
                      open ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: t.faint,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
          if (open)
            Container(
              margin: const EdgeInsets.only(top: 2, bottom: 4),
              decoration: BoxDecoration(
                color: t.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.child,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) return _buildCompact(context);
    // The reference draws these as `rounded-xl` (12) cards, one step tighter
    // than the 16 the app used, so a stack of tool cards reads as a list of
    // chips rather than a column of large panels. One constant drives the card
    // and its header band, which must stay flush.
    const r = 12.0;
    final shape = BorderRadius.circular(r);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: OCSpace.xs),
      decoration: BoxDecoration(
        color: context.oc.surfaceElevated,
        borderRadius: shape,
        // The reference's `shadow-sm`.
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: shape,
              onTap: () => setState(() => open = !open),
              child: Container(
                // `px-space-md py-2 bg-surface-container-high`: the reference
                // separates a tool card's header from its body with a filled
                // band, the same way the code block does.
                padding: const EdgeInsets.fromLTRB(
                  OCSpace.md,
                  8,
                  OCSpace.md,
                  8,
                ),
                decoration: const BoxDecoration(
                  color: OCColors.surfaceHigh,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(r),
                    topRight: Radius.circular(r),
                  ),
                ),
                child: Row(
                  children: [
                    OCIconTile(
                      icon: widget.icon,
                      accent: OCAccent.neutral,
                      size: 28,
                      iconSize: 15,
                      color: widget.color,
                    ),
                    const SizedBox(width: OCSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: OCTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: widget.color,
                            ),
                          ),
                          if (widget.subtitle.isNotEmpty)
                            Text(
                              widget.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: OCTypography.micro.copyWith(
                                color: context.oc.mute,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      open ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: context.oc.faint,
                    ),
                  ],
                ),
              ),
            ),
            if (open) ...[const Divider(height: 1), widget.child],
          ],
        ),
      ),
    );
  }
}

class ToolTile extends StatelessWidget {
  final Part part;
  const ToolTile(this.part, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final st = part.status;
    final color = toolColor(st, cs);
    final dur = part.toolEnd > 0
        ? fmtDuration(part.toolEnd - part.toolStart)
        : '';
    final exit = part.exitCode;

    final title = part.summaryLine.isEmpty ? part.toolName : part.summaryLine;
    final out = part.output.isNotEmpty
        ? part.output
        : (part.errorText.isNotEmpty
              ? part.errorText
              : part.toolMeta['output']?.toString() ?? '');

    return _Collapsible(
      icon: toolIcon(part.toolName),
      title: part.toolName.isEmpty ? 'tool' : part.toolName,
      subtitle: [
        title.replaceAll('\n', ' '),
        if (dur.isNotEmpty) dur,
        if (exit != null) 'exit $exit',
        if (part.truncated) 'truncated',
      ].join(' · '),
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (part.toolInput.isNotEmpty &&
              part.toolInput.keys.any(
                (k) => k != 'command' || part.toolName != 'bash',
              ))
            _InputBlock(json: part.toolInput),
          if (out.isNotEmpty)
            _OutputBlock(
              text: out,
              isError: st == ToolStatus.error || (exit != null && exit != 0),
            ),
        ],
      ),
    );
  }
}

class _InputBlock extends StatelessWidget {
  final Map<String, dynamic> json;
  const _InputBlock({required this.json});

  @override
  Widget build(BuildContext context) {
    final text = json.entries
        .map(
          (e) => '${e.key}: ${e.value is String ? e.value : _pretty(e.value)}',
        )
        .join('\n');
    return Padding(
      padding: const EdgeInsets.fromLTRB(OCSpace.md, OCSpace.sm, OCSpace.md, 0),
      child: Text(
        text,
        style: OCTypography.monoSmall(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  static String _pretty(dynamic v) {
    try {
      return const JsonEncoder.withIndent('  ').convert(v);
    } catch (e) {
      if (kDebugMode) debugPrint('JSON encode failed: $e');
      return v.toString();
    }
  }
}

/// Detects if an error message indicates a permission issue with external paths.
bool _isExternalPermissionError(String text) {
  final lower = text.toLowerCase();
  const permissionKeywords = [
    'permission denied',
    'access denied',
    'eacces',
    'operation not permitted',
    'not allowed',
    'read-only file system',
    'external directory',
  ];
  const pathKeywords = [
    '/storage/',
    '/sdcard/',
    'emulated',
    '/data/',
    '/mnt/',
    'free fire',
  ];
  // These already name the workspace/external-path restriction on their own,
  // so the affordance must not also demand a path keyword — otherwise the most
  // common denial ("... is outside the workspace") never gets an escape hatch.
  const selfSufficient = [
    'outside workspace',
    'external directory',
    'workspace boundary',
    'out of bounds',
    'restricted path',
  ];
  final hasSelfSufficient = selfSufficient.any((k) => lower.contains(k));
  final hasPermissionKeyword = permissionKeywords.any((k) => lower.contains(k));
  final hasPathKeyword = pathKeywords.any((k) => lower.contains(k));
  if (hasSelfSufficient) return true;
  return hasPermissionKeyword && hasPathKeyword;
}

class _OutputBlock extends StatefulWidget {
  final String text;
  final bool isError;
  const _OutputBlock({required this.text, required this.isError, super.key});

  @override
  State<_OutputBlock> createState() => _OutputBlockState();
}

class _OutputBlockState extends State<_OutputBlock> {
  static const _maxLines = 40;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    final store = AppScope.of(context);
    final lines = widget.text.split('\n');
    final truncated = lines.length > _maxLines;
    final shown = _expanded || !truncated
        ? widget.text
        : lines.take(_maxLines).join('\n');
    final showPermissionPrompt =
        widget.isError && _isExternalPermissionError(widget.text);

    // Reference `.out`: always the dark code surface, in both themes.
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.code,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Copy lives on the header, always visible. Making the user select
          // 40 lines of monospace output by hand was the only way to get at it
          // before.
          Row(
            children: [
              Text(
                S.partsOutput,
                style: OCTypography.micro.copyWith(color: t.mute),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  copyToClipboard(context, shown);
                  showSnack(context, S.copied);
                },
                borderRadius: BorderRadius.circular(OCRadius.xs),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OCSpace.sm,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LIcon(LI.copy, size: 12, color: t.mute),
                      const SizedBox(width: 4),
                      Text(
                        S.copy,
                        style: OCTypography.micro.copyWith(color: t.mute),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: OCSpace.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              shown,
              style: OCTypography.mono(
                size: 12,
                color: t.codeInk,
              ).copyWith(height: 1.5),
            ),
          ),
          if (truncated)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '... ${widget.text.length} chars (${lines.length} lines)',
                      style: OCTypography.micro.copyWith(color: t.codeInk),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded ? 'Show less' : 'Show more',
                      style: TextStyle(color: t.codeInk),
                    ),
                  ),
                ],
              ),
            ),
          if (showPermissionPrompt) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: t.accSoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: t.acc),
              ),
              child: Row(
                children: [
                  LIcon(LI.warning, size: 18, color: t.accInk, strokeWidth: 2),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tool blocked: external directory access needed',
                      style: OCTypography.caption.copyWith(color: t.accInk),
                    ),
                  ),
                  OCButton(
                    label: S.partsExternalAccess,
                    variant: OCButtonVariant.smallInline,
                    onPressed: () => store.enableExternalDirectoryAccess(),
                  ),
                ],
              ),
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Clipboard.setData(ClipboardData(text: widget.text)),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: LIcon(LI.copy, size: 15, color: t.codeInk),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
