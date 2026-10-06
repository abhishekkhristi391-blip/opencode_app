part of '../widgets.dart';

/// A header icon button. Exactly 48x48, with a tooltip and a semantics label.
class HeaderButton extends StatelessWidget {
  const HeaderButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
    this.accent = false,
  });

  final LI icon;
  final String label;
  final VoidCallback onTap;
  final int badge;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Tooltip(
          message: label,
          child: Semantics(
            button: true,
            label: label,
            excludeSemantics: true,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: OCSpace.tapTarget,
                  height: OCSpace.tapTarget,
                  child: Center(
                    child: LIcon(icon, size: 22, color: accent ? t.acc : t.ink),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (badge > 0)
          Positioned(right: 2, top: 2, child: CountBadge(n: badge)),
      ],
    );
  }
}

/// Small count bubble, e.g. 4 open todos.
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.n});
  final int n;

  @override
  Widget build(BuildContext context) {
    final t = context.oc;
    return Semantics(
      label: '$n',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: t.acc,
          borderRadius: BorderRadius.circular(OCRadius.pill),
          border: Border.all(color: t.bg, width: 1.5),
        ),
        child: Text(
          n > 99 ? '99+' : '$n',
          style: OCTypography.caption.copyWith(
            color: t.onAcc,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label, value;
  final bool mono;
  final Widget? trailing;
  const InfoRow(
    this.label,
    this.value, {
    super.key,
    this.mono = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: OCSpace.screenX,
      vertical: OCSpace.sm,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 108, child: Text(label, style: OCTypography.caption)),
        Expanded(
          child: mono
              ? Mono(value)
              : SelectableText(
                  value,
                  style: OCTypography.body.copyWith(
                    color: OCColors.textPrimary,
                  ),
                ),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

IconData toolIcon(String name) => switch (name) {
  'bash' || 'shell' => Icons.terminal,
  'read' => Icons.menu_book_outlined,
  'write' || 'edit' || 'patch' || 'multiedit' => Icons.edit_note,
  'grep' || 'search' => Icons.manage_search,
  'glob' || 'list' => Icons.folder_outlined,
  'webfetch' => Icons.cloud_download_outlined,
  'websearch' => Icons.travel_explore,
  'task' || 'agent' => Icons.smart_toy_outlined,
  'todowrite' || 'todoread' => Icons.checklist,
  'invalid' => Icons.block,
  _ => Icons.build_outlined,
};

Color toolColor(ToolStatus s, ColorScheme cs) => switch (s) {
  ToolStatus.completed => OCColors.green,
  ToolStatus.error => cs.error,
  ToolStatus.running => OCColors.warning,
  ToolStatus.pending => cs.outline,
  ToolStatus.unknown => cs.outline,
};
