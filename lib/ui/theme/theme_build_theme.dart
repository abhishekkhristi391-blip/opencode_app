part of '../theme.dart';

ThemeData _buildTheme() {
  const t = OCTokens.dark;
  // M3 roles as the design defines them: primary is WHITE (the filled action),
  // secondary is TERRACOTTA (selected / active / warm highlight). The old
  // scheme had `primary: accent` and `secondary: textSecondary`, which is why
  // "secondary" call sites ended up grey and every button ended up orange.
  const cs = ColorScheme(
    brightness: Brightness.dark,
    primary: OCColors.cta,
    onPrimary: OCColors.onCta,
    primaryContainer: OCColors.surfaceHigh,
    onPrimaryContainer: OCColors.textPrimary,
    secondary: OCColors.accent,
    onSecondary: OCColors.onAccent,
    secondaryContainer: OCColors.secondary,
    onSecondaryContainer: OCColors.onSecondary,
    tertiary: OCColors.tertiary,
    onTertiary: OCColors.onTertiary,
    tertiaryContainer: OCColors.deep,
    onTertiaryContainer: OCColors.tertiary,
    error: OCColors.error,
    onError: OCColors.onCta,
    errorContainer: OCColors.errorSoft,
    onErrorContainer: OCColors.errorInk,
    surface: OCColors.bg,
    onSurface: OCColors.textPrimary,
    onSurfaceVariant: OCColors.textSecondary,
    surfaceContainerLowest: OCColors.surfaceLowest,
    surfaceContainerLow: OCColors.surface,
    surfaceContainer: OCColors.surfaceElevated,
    surfaceContainerHigh: OCColors.surfaceHigh,
    surfaceContainerHighest: OCColors.surfaceHighest,
    surfaceDim: OCColors.surfaceLowest,
    surfaceBright: OCColors.surfaceBright,
    outline: OCColors.borderStrong,
    outlineVariant: OCColors.border,
    scrim: Color(0xFF000000),
    surfaceTint: Colors.transparent,
    inverseSurface: OCColors.textPrimary,
    onInverseSurface: OCColors.bg,
    inversePrimary: OCColors.accent,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: cs,
    scaffoldBackgroundColor: t.bg,
    canvasColor: t.bg,
    extensions: const <ThemeExtension<dynamic>>[t],

    fontFamily: OCTypography.fontFamily,
    fontFamilyFallback: OCTypography._fallback,
    splashFactory: InkSparkle.splashFactory,

    textTheme: _textTheme(t),
    primaryTextTheme: _textTheme(t),

    // Every Material surface reads a token. This is the single most important
    // line in the file: a dialog, a menu or a text selection that paints
    // itself white is now impossible.
    appBarTheme: AppBarTheme(
      backgroundColor: t.bg,
      foregroundColor: t.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: OCTypography.title.copyWith(color: t.ink),
    ),
    cardTheme: CardThemeData(
      color: t.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      // No border. The design separates cards with the container ladder
      // (`container-low` on `surface`) plus a shadow, never with an outline;
      // the hairline here is what made every card read as a bordered box.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OCRadius.card),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: t.line,
      thickness: 1,
      space: 1,
      indent: 0,
      endIndent: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: t.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OCRadius.lg),
      ),
      titleTextStyle: OCTypography.title.copyWith(color: t.ink),
      contentTextStyle: OCTypography.body.copyWith(color: t.mute),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: t.card,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: t.card,
      elevation: 0,
      // 20dp top corners, square bottom: the sheet is anchored to the screen
      // edge, so rounding the bottom would show the scaffold through it.
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(OCRadius.sheet),
        ),
      ),
      dragHandleColor: t.line,
      dragHandleSize: const Size(36, 36),
      showDragHandle: true,
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(t.card),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(8),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OCRadius.card),
          ),
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: t.card,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OCRadius.card),
      ),
      textStyle: OCTypography.body.copyWith(color: t.ink),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: BorderRadius.circular(OCRadius.xs),
        border: Border.all(color: t.line),
      ),
      textStyle: OCTypography.caption.copyWith(color: t.ink),
      waitDuration: const Duration(milliseconds: 500),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: t.surfaceElevated,
      contentTextStyle: OCTypography.body.copyWith(color: t.ink),
      actionTextColor: OCColors.cta,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OCRadius.card),
      ),
      insetPadding: const EdgeInsets.all(OCSpace.lg),
      elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surfaceElevated,
      hintStyle: OCTypography.body.copyWith(color: t.faint),
      labelStyle: OCTypography.meta.copyWith(color: t.mute),
      floatingLabelStyle: OCTypography.meta.copyWith(color: t.mute),
      helperStyle: OCTypography.caption.copyWith(color: t.mute),
      prefixIconColor: t.mute,
      suffixIconColor: t.mute,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: OCSpace.md,
        vertical: OCSpace.md,
      ),
      border: _fieldBorder(t.line),
      enabledBorder: _fieldBorder(t.line),
      focusedBorder: _fieldBorder(OCColors.cta, width: 2),
      errorBorder: _fieldBorder(t.err),
      focusedErrorBorder: _fieldBorder(t.err, width: 2),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? OCColors.onAccent : t.mute,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? OCColors.accent
            : t.surfaceElevated,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? OCColors.accent : t.line,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? OCColors.accent
            : Colors.transparent,
      ),
      checkColor: const WidgetStatePropertyAll(OCColors.onAccent),
      side: BorderSide(color: t.line),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OCRadius.xs),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: t.card,
      selectedColor: t.accSoft,
      side: BorderSide(color: t.line),
      labelStyle: OCTypography.meta.copyWith(color: t.ink),
      secondaryLabelStyle: OCTypography.meta.copyWith(color: t.ink),
      iconTheme: IconThemeData(color: t.mute, size: 16),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: OCSpace.sm),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: OCColors.cta,
      linearTrackColor: Colors.transparent,
      circularTrackColor: Colors.transparent,
    ),
    // One scrollbar for the whole app: right edge, 3dp, muted, fades out when
    // idle. Nothing else in the app paints a bar. `thumbVisibility: false` means
    // it can only appear in response to a scroll or a drag, so a list that does
    // not overflow can never show one - which is the whole point.
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.dragged) ? OCColors.cta : t.mute,
      ),
      trackColor: const WidgetStatePropertyAll(null),
      thickness: const WidgetStatePropertyAll(3),
      radius: const Radius.circular(OCRadius.full),
      thumbVisibility: const WidgetStatePropertyAll(false),
      interactive: true,
    ),
    splashColor: OCColors.accent.withValues(alpha: 0.12),
    highlightColor: OCColors.accent.withValues(alpha: 0.06),
    listTileTheme: ListTileThemeData(
      textColor: t.ink,
      iconColor: t.mute,
      titleTextStyle: OCTypography.title.copyWith(color: t.ink),
      subtitleTextStyle: OCTypography.caption.copyWith(color: t.mute),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? OCColors.accent : t.line,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

OutlineInputBorder _fieldBorder(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(OCRadius.sm),
      borderSide: BorderSide(color: color, width: width),
    );

TextTheme _textTheme(OCTokens t) => TextTheme(
  // Serif for the display/headline roles, Inter below. A Material widget that
  // reaches for `titleLarge` gets a serif card title, which is what the design
  // does with `text-[20px] font-serif font-semibold`.
  displayLarge: OCTypography.headline.copyWith(color: t.ink),
  displayMedium: OCTypography.headline.copyWith(color: t.ink),
  displaySmall: OCTypography.titleLarge.copyWith(color: t.ink),
  headlineLarge: OCTypography.headline.copyWith(color: t.ink),
  headlineMedium: OCTypography.headline.copyWith(color: t.ink),
  headlineSmall: OCTypography.titleLarge.copyWith(color: t.ink),
  titleLarge: OCTypography.titleLarge.copyWith(color: t.ink),
  titleMedium: OCTypography.title.copyWith(color: t.ink),
  titleSmall: OCTypography.meta.copyWith(color: t.ink),
  bodyLarge: OCTypography.body.copyWith(color: t.ink),
  bodyMedium: OCTypography.body.copyWith(color: t.ink),
  bodySmall: OCTypography.caption.copyWith(color: t.mute),
  labelLarge: OCTypography.button.copyWith(color: t.ink),
  labelMedium: OCTypography.meta.copyWith(color: t.ink),
  labelSmall: OCTypography.micro.copyWith(color: t.mute),
);
