// OpenCode design system — dark theme first, matches Linear / Claude aesthetic.
// One source of truth for colors, typography, spacing, shapes, elevation.

import 'package:flutter/material.dart';

/// Semantic color roles used across the app.
/// All widgets should reference these, never hard-code colours.
class OCColors {
  // Base surfaces (near-black, subtle elevation by lightness)
  static const surface = Color(0xFF0A0B0E);
  static const surfaceLow = Color(0xFF101216);
  static const surfaceHigh = Color(0xFF1A1D23);
  static const surfaceHighest = Color(0xFF242830);

  // Accent — single brand colour, used for primary actions, links, focus
  static const accent = Color(0xFF6C63FF);
  static const accentHover = Color(0xFF8680FF);
  static const accentSoft = Color(0xFF6C63FF);

  // Status colours (kept accessible on dark surfaces)
  static const success = Color(0xFF3DDC84);
  static const warning = Color(0xFFFFB020);
  static const error = Color(0xFFFF5F57);
  static const info = Color(0xFF64B5F6);

  // Text hierarchy
  static const textPrimary = Color(0xFFE8EAED);
  static const textSecondary = Color(0xFF9AA0A6);
  static const textMuted = Color(0xFF6B7280);
  static const textOnAccent = Colors.white;

  // Borders / dividers — thin, low contrast
  static const border = Color(0xFF2D3139);
  static const borderFocus = Color(0xFF6C63FF);

  // Selection / highlight
  static const selection = Color(0xFF6C63FF);

  // Code block background
  static const codeBg = Color(0xFF0D1117);
  static const codeBorder = Color(0xFF30363D);
}

/// 4/8 pt spacing scale.
class OCSpace {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}

/// Border radius scale.
class OCRadius {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const full = 9999.0;
}

/// Elevation expressed as surface lightness + subtle shadow.
class OCElevation {
  static const level0 = 0.0;
  static const level1 = 1.0;  // cards, sheets
  static const level2 = 3.0;  // dropdowns, tooltips
  static const level3 = 6.0;  // modals
}

/// Typography — single font pairing.
/// Inter for UI, JetBrains Mono for code.
class OCTypography {
  static const _uiFamily = 'Inter';
  static const _monoFamily = 'JetBrains Mono';

  // TextStyle helpers that merge with theme.textTheme for scaling.
  static TextStyle displayLarge(BuildContext context, {Color? color, FontWeight? weight}) =>
      Theme.of(context).textTheme.displayLarge!.copyWith(
        fontFamily: _uiFamily,
        color: color ?? OCColors.textPrimary,
        fontWeight: weight ?? FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle headline(BuildContext context, {Color? color, FontWeight? weight}) =>
      Theme.of(context).textTheme.headlineMedium!.copyWith(
        fontFamily: _uiFamily,
        color: color ?? OCColors.textPrimary,
        fontWeight: weight ?? FontWeight.w600,
        height: 1.3,
      );

  static TextStyle title(BuildContext context, {Color? color, FontWeight? weight}) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
        fontFamily: _uiFamily,
        color: color ?? OCColors.textPrimary,
        fontWeight: weight ?? FontWeight.w600,
        height: 1.4,
      );

  static TextStyle bodyLarge(BuildContext context, {Color? color}) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontFamily: _uiFamily,
        color: color ?? OCColors.textPrimary,
        fontSize: 15.5,
        height: 1.55,
      );

  static TextStyle body(BuildContext context, {Color? color}) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(
        fontFamily: _uiFamily,
        color: color ?? OCColors.textPrimary,
        fontSize: 14.5,
        height: 1.55,
      );

  static TextStyle bodySmall(BuildContext context, {Color? color}) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(
        fontFamily: _uiFamily,
        color: color ?? OCColors.textSecondary,
        fontSize: 12.5,
        height: 1.5,
      );

  static TextStyle label(BuildContext context, {Color? color}) =>
      Theme.of(context).textTheme.labelLarge!.copyWith(
        fontFamily: _uiFamily,
        color: color ?? OCColors.textSecondary,
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      );

  static TextStyle mono(BuildContext context, {Color? color, double size = 12.5}) =>
      TextStyle(
        fontFamily: _monoFamily,
        fontFamilyFallback: const ['monospace'],
        fontSize: size,
        height: 1.45,
        color: color ?? OCColors.textPrimary,
      );

  static TextStyle monoSmall(BuildContext context, {Color? color}) =>
      mono(context, color: color, size: 11.5);
}

/// Light theme derived from dark (for completeness).
ThemeData buildLightTheme() {
  final cs = ColorScheme.fromSeed(
    seedColor: OCColors.accent,
    brightness: Brightness.light,
    surface: const Color(0xFFFAFAFA),
    onSurface: const Color(0xFF1A1A1A),
    surfaceContainerLow: const Color(0xFFF5F5F5),
    surfaceContainerHigh: const Color(0xFFEEEEEE),
    surfaceContainerHighest: const Color(0xFFE0E0E0),
  );
  return _baseTheme(cs);
}

/// Dark theme — the default.
ThemeData buildDarkTheme() {
  final cs = ColorScheme.fromSeed(
    seedColor: OCColors.accent,
    brightness: Brightness.dark,
    primary: OCColors.accent,
    onPrimary: OCColors.textOnAccent,
    secondary: OCColors.accentSoft,
    onSecondary: OCColors.textOnAccent,
    tertiary: OCColors.info,
    onTertiary: OCColors.textOnAccent,
    error: OCColors.error,
    onError: OCColors.textOnAccent,
    surface: OCColors.surface,
    onSurface: OCColors.textPrimary,
    surfaceContainerLow: OCColors.surfaceLow,
    surfaceContainerHigh: OCColors.surfaceHigh,
    surfaceContainerHighest: OCColors.surfaceHighest,
    onSurfaceVariant: OCColors.textSecondary,
    outline: OCColors.border,
    outlineVariant: OCColors.border,
    shadow: Colors.black,
    inverseSurface: const Color(0xFFF5F5F5),
    onInverseSurface: OCColors.surface,
  );
  return _baseTheme(cs);
}

ThemeData _baseTheme(ColorScheme cs) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: cs.surface,
    fontFamily: OCTypography._uiFamily,

    // --- AppBar ---
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: OCElevation.level0,
      scrolledUnderElevation: OCElevation.level1,
      centerTitle: false,
      titleTextStyle: OCTypography.title(cs.surface, color: cs.onSurface),
      iconTheme: IconThemeData(color: cs.onSurface, size: 22),
      actionsIconTheme: IconThemeData(color: cs.onSurface, size: 22),
    ),

    // --- Cards ---
    cardTheme: CardThemeData(
      elevation: OCElevation.level0,
      color: cs.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OCRadius.md)),
      margin: EdgeInsets.zero,
    ),

    // --- Inputs ---
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: OCSpace.md, vertical: OCSpace.sm),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OCRadius.sm),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OCRadius.sm),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OCRadius.sm),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OCRadius.sm),
        borderSide: BorderSide(color: cs.error),
      ),
      labelStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 13.5),
      hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 13.5),
      floatingLabelStyle: TextStyle(color: cs.primary),
    ),

    // --- Buttons ---
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: OCSpace.lg, vertical: OCSpace.sm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OCRadius.sm)),
        textStyle: OCTypography.label(cs.surface, color: cs.onPrimary),
        minimumSize: const Size(0, 44), // accessibility
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.primary,
        side: BorderSide(color: cs.outline),
        padding: const EdgeInsets.symmetric(horizontal: OCSpace.lg, vertical: OCSpace.sm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OCRadius.sm)),
        textStyle: OCTypography.label(cs.surface, color: cs.primary),
        minimumSize: const Size(0, 44),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cs.primary,
        padding: const EdgeInsets.symmetric(horizontal: OCSpace.md, vertical: OCSpace.xs),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OCRadius.sm)),
        textStyle: OCTypography.label(cs.surface, color: cs.primary),
        minimumSize: const Size(0, 44),
      ),
    ),

    // --- Chips ---
    chipTheme: ChipThemeData(
      backgroundColor: cs.surfaceContainerHighest,
      selectedColor: cs.primaryContainer,
      disabledColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
      labelStyle: OCTypography.label(cs.surface),
      secondaryLabelStyle: OCTypography.label(cs.surface, color: cs.onPrimaryContainer),
      padding: const EdgeInsets.symmetric(horizontal: OCSpace.xs, vertical: OCSpace.xxs),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OCRadius.full)),
      side: BorderSide.none,
      brightness: Brightness.dark,
    ),

    // --- Dividers ---
    dividerTheme: DividerThemeData(
      color: cs.outlineVariant,
      thickness: 1,
      space: OCSpace.sm,
      indent: 0,
      endIndent: 0,
    ),

    // --- Lists ---
    listTileTheme: ListTileThemeData(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: OCSpace.lg, vertical: OCSpace.xs),
      titleTextStyle: OCTypography.body(cs.surface),
      subtitleTextStyle: OCTypography.bodySmall(cs.surface),
      leadingAndTrailingTextStyle: OCTypography.bodySmall(cs.surface),
      iconColor: cs.onSurfaceVariant,
      textColor: cs.onSurface,
      selectedTileColor: cs.primaryContainer.withValues(alpha: 0.3),
      selectedColor: cs.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OCRadius.sm)),
    ),

    // --- Dialogs ---
    dialogTheme: DialogThemeData(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: OCElevation.level3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OCRadius.lg)),
      titleTextStyle: OCTypography.title(cs.surface),
      contentTextStyle: OCTypography.body(cs.surface),
      insetPadding: const EdgeInsets.all(OCSpace.lg),
    ),

    // --- Bottom Sheets ---
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: OCElevation.level2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(OCRadius.xl)),
      ),
      modalBarrierColor: Colors.black.withValues(alpha: 0.6),
      dragHandleColor: cs.outlineVariant,
      showDragHandle: true,
    ),

    // --- Navigation ---
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: OCElevation.level1,
      height: 62,
      indicatorColor: cs.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return OCTypography.label(cs.surface, color: cs.primary);
        }
        return OCTypography.label(cs.surface, color: cs.onSurfaceVariant);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: cs.primary, size: 22);
        }
        return IconThemeData(color: cs.onSurfaceVariant, size: 22);
      }),
    ),

    // --- Tooltips ---
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: cs.inverseSurface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(OCRadius.sm),
      ),
      textStyle: OCTypography.label(cs.surface, color: cs.onInverseSurface),
      padding: const EdgeInsets.symmetric(horizontal: OCSpace.md, vertical: OCSpace.xs),
      verticalOffset: 8,
      preferBelow: true,
    ),

    // --- SnackBar (replaced by custom toast, but keep sane defaults) ---
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cs.inverseSurface,
      contentTextStyle: OCTypography.body(cs.surface, color: cs.onInverseSurface),
      actionTextColor: cs.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OCRadius.md)),
      elevation: OCElevation.level2,
    ),

    // --- Progress Indicators ---
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: cs.primary,
      linearTrackColor: cs.surfaceContainerHighest,
      circularTrackColor: cs.surfaceContainerHighest,
    ),

    // --- Selection ---
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: cs.primary,
      selectionColor: cs.primary.withValues(alpha: 0.3),
      selectionHandleColor: cs.primary,
    ),

    // --- Visual Density ---
    visualDensity: VisualDensity.standard,
  );
}