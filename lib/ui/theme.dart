// Design tokens — "Playful Soft-UI" (design-system.json v1.0.0).
// Single source of truth for colour, type, spacing, shape, elevation and motion.
// Nothing in the app should hard-code a colour, radius, shadow or text size.

import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

/// Semantic colour roles used across the app.
/// All widgets should reference these, never hard-code colours.
class OCColors {
  // --- neutrals -------------------------------------------------------
  static const canvas = Color(0xFFF0F0F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSubtle = Color(0xFFF6F6FA);
  static const surfaceMuted = Color(0xFFEFEFF5);
  static const borderHairline = Color(0xFFECECF2);
  static const divider = Color(0xFFF0F0F4);
  static const textPrimary = Color(0xFF0D0D12);
  static const textSecondary = Color(0xFF6B6B7B);
  static const textTertiary = Color(0xFFA0A0B0);
  static const textInverse = Color(0xFFFFFFFF);

  // --- brand accents (base / soft / tint + accessible ink) -----------
  static const purple = Color(0xFF8B5CF6);
  static const purpleSoft = Color(0xFFC7B8F5);
  static const purpleTint = Color(0xFFEDE7FD);
  static const purpleInk = Color(0xFF5B21B6);

  static const orange = Color(0xFFFF8A1F);
  static const orangeDeep = Color(0xFFF97316);
  static const orangeBright = Color(0xFFFFA033);
  static const orangeTrack = Color(0xFFFFE6B8);
  static const orangeTint = Color(0xFFFFF1E3);
  static const orangeInk = Color(0xFF9A3412);

  static const pink = Color(0xFFF472B6);
  static const pinkHot = Color(0xFFE879F9);
  static const pinkTint = Color(0xFFFCE7F3);
  static const pinkInk = Color(0xFFA21CAF);

  static const yellow = Color(0xFFFFD23F);
  static const yellowSoft = Color(0xFFFFE48A);
  static const yellowTint = Color(0xFFFFF7D6);
  static const yellowInk = Color(0xFFA16207);

  static const blue = Color(0xFF4C9AFF);
  static const blueSky = Color(0xFFBFE3FF);
  static const blueTint = Color(0xFFE6F2FF);
  static const blueInk = Color(0xFF1D4ED8);

  static const green = Color(0xFF34C759);
  static const greenTint = Color(0xFFE4F8E8);
  static const greenInk = Color(0xFF15803D);

  static const red = Color(0xFFEF4444);
  static const redTint = Color(0xFFFEE8E8);
  static const redInk = Color(0xFFB42318);

  // --- semantic -------------------------------------------------------
  static const ctaSolid = textPrimary; // dominant CTA is black
  static const ctaAlt = orange;
  static const success = green;
  static const danger = red;
  static const warning = Color(0xFFFFB020);
  static const info = blue;
  static const toggleOn = orange;
  static const toggleOff = Color(0xFFD9D9E3);

  // --- code surfaces --------------------------------------------------
  static const codeBg = surfaceSubtle;
  static const codeBorder = borderHairline;

  // --- aliases kept so existing call sites keep compiling -------------
  static const accent = ctaSolid;
  static const accentHover = Color(0xFF2A2A35);
  static const accentSoft = purple;
  static const error = danger;
  static const textOnAccent = textInverse;
  static const textMuted = textSecondary;
  static const surfaceLow = surfaceSubtle;
  static const surfaceHigh = surfaceMuted;
  static const surfaceHighest = surfaceMuted;
  static const border = borderHairline;
  static const borderFocus = purple;
  static const selection = purple;
}

/// Soft, low-opacity, slightly purple-tinted shadows. Prefer shadow over borders.
class OCShadow {
  static const card = [
    BoxShadow(color: Color(0x0F141432), blurRadius: 20, offset: Offset(0, 4)),
  ];
  static const cardHover = [
    BoxShadow(color: Color(0x1A141432), blurRadius: 28, offset: Offset(0, 8)),
  ];
  static const floatingCta = [
    BoxShadow(color: Color(0x2E000000), blurRadius: 24, offset: Offset(0, 10)),
  ];
  static const coloredCtaGlow = [
    BoxShadow(color: Color(0x59FF6FA8), blurRadius: 20, offset: Offset(0, 8)),
  ];
  static const sheet = [
    BoxShadow(color: Color(0x1A141432), blurRadius: 40, offset: Offset(0, -8)),
  ];
  static const segmentedActive = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const toggleThumb = [
    BoxShadow(color: Color(0x2E141432), blurRadius: 6, offset: Offset(0, 2)),
  ];
  static const none = <BoxShadow>[];
}

/// Pastel gradients for heroes, CTAs, meters and highlight numbers.
class OCGradient {
  static const heroSky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFBFE3FF), Color(0xFFE9F3FF), Color(0xFFFFFFFF)],
    stops: [0, 0.6, 1],
  );
  static const heroPastelBlend = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD6E8), Color(0xFFE1D4FF), Color(0xFFC9F0FF)],
  );
  static const heroMintToCream = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE5F7D8), Color(0xFFFFF6D9)],
  );
  static const heroPurple = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFC9B5FF), Color(0xFFA78BFA)],
  );
  static const heroWarmCream = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF3C9), Color(0xFFFFFFFF)],
  );
  static const ctaSunset = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF9A5A), Color(0xFFFF6FA8), Color(0xFFE879F9)],
    stops: [0, 0.6, 1],
  );
  static const ctaOrangeSoft = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [OCColors.orangeBright, OCColors.orange],
  );
  static const cardVisualPink = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9A8E8), Color(0xFFE879F9)],
  );
  static const progressWarm = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFFB84D), Color(0xFFFFD58A)],
  );
  static const meterMulti = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF9A5A),
      Color(0xFFFFD23F),
      Color(0xFF7EE0A8),
      Color(0xFF8B5CF6),
    ],
    stops: [0, 0.35, 0.7, 1],
  );
  static const number = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFF472B6)],
  );
}

/// 4pt spacing scale + layout roles.
class OCSpace {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;

  static const scale = [4.0, 8.0, 12.0, 16.0, 20.0, 24.0, 32.0, 40.0];
  static const screenX = 16.0;
  static const card = 16.0;
  static const cardLarge = 20.0;
  static const gapCards = 12.0;
  static const gapRows = 8.0;
  static const gapIconText = 12.0;
  static const gapGrid = 12.0;
  static const sectionGap = 20.0;
  static const ctaBottom = 24.0;
  static const safeBottom = 24.0;

  /// Accessibility: never ship a tap target smaller than this.
  static const tapTarget = 44.0;
}

/// Squircle-and-pills shape language. No sharp corners.
class OCRadius {
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0; // inner cells, icon tiles
  static const lg = 20.0;
  static const xl = 28.0;
  static const full = 9999.0; // pills

  // named roles
  static const card = 24.0;
  static const inner = 16.0;
  static const icon = 16.0;
  static const tile = 16.0;
  static const sheet = 32.0;

  static const avatarRadius = Radius.circular(full);
}

/// Springy, playful, quick.
class OCMotion {
  static const pressScale = 0.97; // buttons scale to 0.97 on press
  static const micro = Duration(milliseconds: 120);
  static const base = Duration(milliseconds: 220);
  static const emphasis = Duration(milliseconds: 360);

  /// cubic-bezier(0.2, 0.8, 0.2, 1)
  static const standard = Cubic(0.2, 0.8, 0.2, 1);
  static const enter = Curves.easeOutBack; // springy overshoot

  // spring: stiffness 300, damping 22
  static const springStiffness = 300.0;
  static const springDamping = 22.0;

  static SpringDescription get spring => const SpringDescription(
    mass: 1,
    stiffness: springStiffness,
    damping: springDamping,
  );
}

/// Typography — Plus Jakarta Sans, with Poppins / Inter fallbacks.
class OCTypography {
  static const _uiFamily = 'PlusJakartaSans';
  static const _fallback = ['Poppins', 'Inter', 'Roboto'];
  static const _monoFamily = 'monospace';

  static const fontFamily = _uiFamily;
  static const monoFamily = _monoFamily;

  static TextStyle _sans({
    required double size,
    required FontWeight weight,
    double height = 1.4,
    double spacing = 0,
    Color? color,
    FontStyle? style,
  }) => TextStyle(
    fontFamily: _uiFamily,
    fontFamilyFallback: _fallback,
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: spacing,
    color: color,
    fontStyle: style,
  );

  // --- scale -----------------------------------------------------------

  /// 32 / 800 / 1.05 / -0.03em — hero headlines.
  static final displayXl = _sans(
    size: 32,
    weight: FontWeight.w800,
    height: 1.05,
    spacing: -0.96,
  );

  /// 36 / 700 / 1.1 / -0.02em — big amounts, may use gradient text.
  static final displayAmount = _sans(
    size: 36,
    weight: FontWeight.w700,
    height: 1.1,
    spacing: -0.72,
  );

  /// 24 / 700 / 1.2 / -0.02em
  static final h1 = _sans(
    size: 24,
    weight: FontWeight.w700,
    height: 1.2,
    spacing: -0.48,
  );

  /// 20 / 700 / 1.25 / -0.01em — card headings.
  static final h2 = _sans(
    size: 20,
    weight: FontWeight.w700,
    height: 1.25,
    spacing: -0.2,
  );

  /// 16 / 600 / 1.3 — card titles, list row titles.
  static final h3 = _sans(size: 16, weight: FontWeight.w600, height: 1.3);

  /// 14 / 500 / 1.4
  static final body = _sans(size: 14, weight: FontWeight.w500, height: 1.4);

  /// 14 / 600 / 1.4
  static final bodyStrong = _sans(
    size: 14,
    weight: FontWeight.w600,
    height: 1.4,
  );

  /// 12 / 500 / 1.35 — grey supporting text.
  static final caption = _sans(
    size: 12,
    weight: FontWeight.w500,
    height: 1.35,
    color: OCColors.textSecondary,
  );

  /// 10 / 500 / 1.3 — helper text, sub-labels.
  static final micro = _sans(
    size: 10,
    weight: FontWeight.w500,
    height: 1.3,
    color: OCColors.textTertiary,
  );

  /// 15 / 700 / 1.0 — button labels.
  static final button = _sans(size: 15, weight: FontWeight.w700, height: 1.0);

  /// Tabular figures for prices / balances.
  static TextStyle numeric({
    double size = 14,
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) => _sans(
    size: size,
    weight: weight,
    height: 1.2,
    color: color,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  // --- mono ------------------------------------------------------------

  static TextStyle mono({Color? color, double size = 12.5}) => TextStyle(
    fontFamily: _monoFamily,
    fontFamilyFallback: _fallback,
    fontSize: size,
    height: 1.45,
    color: color,
  );

  static TextStyle monoSmall({Color? color}) => mono(color: color, size: 11.5);

  // --- legacy aliases (kept for existing call sites) -------------------

  static TextStyle get displayLarge => displayXl;
  static TextStyle get headline => h1;
  static TextStyle get title => h2;
  static TextStyle get bodyLarge => h3;
  static TextStyle get bodySmall => caption;
  static TextStyle get label => _sans(
    size: 12,
    weight: FontWeight.w500,
    height: 1.35,
    color: OCColors.textSecondary,
  );

  /// Helper to create a TextStyle with a specific color from the base style.
  static TextStyle withColor(TextStyle base, Color color) =>
      base.copyWith(color: color);
}

extension _TextStyleExt on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
}

/// Light theme — the design system's default. Pale lavender-grey canvas.
ThemeData buildLightTheme() {
  const cs = ColorScheme(
    brightness: Brightness.light,
    primary: OCColors.ctaSolid,
    onPrimary: OCColors.textInverse,
    primaryContainer: OCColors.purpleTint,
    onPrimaryContainer: OCColors.purpleInk,
    secondary: OCColors.orange,
    onSecondary: OCColors.textInverse,
    secondaryContainer: OCColors.orangeTint,
    onSecondaryContainer: OCColors.orangeInk,
    tertiary: OCColors.pink,
    onTertiary: OCColors.textInverse,
    tertiaryContainer: OCColors.pinkTint,
    onTertiaryContainer: OCColors.pinkInk,
    error: OCColors.danger,
    onError: OCColors.textInverse,
    errorContainer: OCColors.redTint,
    onErrorContainer: OCColors.redInk,
    surface: OCColors.surface,
    onSurface: OCColors.textPrimary,
    onSurfaceVariant: OCColors.textSecondary,
    surfaceContainerLowest: OCColors.surface,
    surfaceContainerLow: OCColors.surfaceSubtle,
    surfaceContainer: OCColors.canvas,
    surfaceContainerHigh: OCColors.surfaceMuted,
    surfaceContainerHighest: OCColors.surfaceMuted,
    surfaceBright: OCColors.surface,
    surfaceDim: const Color(0xFFE3E3EC),
    outline: OCColors.textSecondary,
    outlineVariant: OCColors.borderHairline,
    shadow: const Color(0xFF141432),
    scrim: const Color(0xFF141432),
    inverseSurface: OCColors.textPrimary,
    onInverseSurface: OCColors.textInverse,
    inversePrimary: OCColors.surfaceSubtle,
    surfaceTint: Colors.transparent,
  );
  return _baseTheme(cs);
}

/// Dark theme — same tokens, dimmed surfaces. Used when the OS asks for dark.
ThemeData buildDarkTheme() {
  const cs = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF5F5F7),
    onPrimary: OCColors.textPrimary,
    primaryContainer: Color(0xFF2E2440),
    onPrimaryContainer: Color(0xFFE4D7FF),
    secondary: OCColors.orange,
    onSecondary: OCColors.textPrimary,
    secondaryContainer: Color(0xFF3A2A18),
    onSecondaryContainer: Color(0xFFFFE0BF),
    tertiary: OCColors.pinkHot,
    onTertiary: OCColors.textPrimary,
    tertiaryContainer: Color(0xFF3B1F33),
    onTertiaryContainer: Color(0xFFFFD6EC),
    error: Color(0xFFFF6B6B),
    onError: OCColors.textPrimary,
    errorContainer: Color(0xFF3D1F1F),
    onErrorContainer: Color(0xFFFFD5D5),
    surface: Color(0xFF0D0D12),
    onSurface: Color(0xFFF3F3F7),
    onSurfaceVariant: Color(0xFFA9A9BA),
    surfaceContainerLowest: Color(0xFF0D0D12),
    surfaceContainerLow: Color(0xFF15161C),
    surfaceContainer: Color(0xFF1A1B22),
    surfaceContainerHigh: Color(0xFF22232B),
    surfaceContainerHighest: Color(0xFF2A2C35),
    surfaceBright: Color(0xFF34363F),
    surfaceDim: Color(0xFF08080C),
    outline: Color(0xFF9A9AAB),
    outlineVariant: Color(0xFF2A2C35),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFF3F3F7),
    onInverseSurface: Color(0xFF14141B),
    inversePrimary: Color(0xFF1F1F27),
    surfaceTint: Colors.transparent,
  );
  return _baseTheme(cs);
}

/// The single entry point that turns [cs] into the app's ThemeData.
ThemeData _baseTheme(ColorScheme cs) {
  final isLight = cs.brightness == Brightness.light;
  final tt = isLight
      ? OCTypography.label
      : OCTypography.label.withColor(cs.onSurfaceVariant);

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    // Design system: the screen background is the canvas tint, cards sit on top of it.
    canvasColor: isLight ? OCColors.canvas : cs.surface,
    scaffoldBackgroundColor: isLight ? OCColors.canvas : cs.surface,
    fontFamily: OCTypography.fontFamily,
    fontFamilyFallback: OCTypography._fallback,
    splashFactory: InkSparkle.splashFactory,

    // --- type scale -----------------------------------------------------
    textTheme: TextTheme(
      displayLarge: OCTypography.displayXl.withColor(cs.onSurface),
      displayMedium: OCTypography.displayAmount.withColor(cs.onSurface),
      headlineLarge: OCTypography.h1.withColor(cs.onSurface),
      headlineMedium: OCTypography.h1.withColor(cs.onSurface),
      headlineSmall: OCTypography.h2.withColor(cs.onSurface),
      titleLarge: OCTypography.h2.withColor(cs.onSurface),
      titleMedium: OCTypography.h3.withColor(cs.onSurface),
      titleSmall: OCTypography.bodyStrong.withColor(cs.onSurface),
      bodyLarge: OCTypography.h3.withColor(cs.onSurface),
      bodyMedium: OCTypography.body.withColor(cs.onSurface),
      bodySmall: OCTypography.caption.withColor(cs.onSurfaceVariant),
      labelLarge: OCTypography.button.withColor(cs.onPrimary),
      labelMedium: tt,
      labelSmall: OCTypography.micro.withColor(cs.onSurfaceVariant),
    ),

    // --- AppBar ---------------------------------------------------------
    appBarTheme: AppBarTheme(
      backgroundColor: isLight ? OCColors.canvas : cs.surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: cs.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: OCTypography.h3.withColor(cs.onSurface),
      iconTheme: IconThemeData(color: cs.onSurface, size: 22),
      actionsIconTheme: IconThemeData(color: cs.onSurface, size: 22),
    ),

    // --- Cards ----------------------------------------------------------
    cardTheme: CardThemeData(
      elevation: 0,
      color: cs.surface,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OCRadius.card),
      ),
    ),

    // --- Inputs ---------------------------------------------------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: OCSpace.md,
        vertical: OCSpace.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OCRadius.inner),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OCRadius.inner),
        borderSide: const BorderSide(color: OCColors.borderHairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OCRadius.inner),
        borderSide: const BorderSide(color: OCColors.orange, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OCRadius.inner),
        borderSide: const BorderSide(color: OCColors.danger, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(OCRadius.inner),
        borderSide: const BorderSide(color: OCColors.danger, width: 1.5),
      ),
      labelStyle: OCTypography.caption.withColor(cs.onSurfaceVariant),
      hintStyle: OCTypography.body.withColor(
        cs.onSurfaceVariant.withValues(alpha: 0.7),
      ),
      floatingLabelStyle: OCTypography.bodyStrong.withColor(OCColors.orangeInk),
    ),

    // --- Buttons --------------------------------------------------------
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        disabledBackgroundColor: cs.primary.withValues(alpha: 0.4),
        disabledForegroundColor: cs.onPrimary.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(
          horizontal: OCSpace.lg,
          vertical: OCSpace.md,
        ),
        minimumSize: const Size(0, OCSpace.tapTarget),
        shape: const StadiumBorder(),
        textStyle: OCTypography.button,
        elevation: 0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        minimumSize: const Size(0, OCSpace.tapTarget),
        shape: const StadiumBorder(),
        textStyle: OCTypography.button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.onSurface,
        backgroundColor: cs.surfaceContainer,
        side: const BorderSide(color: OCColors.borderHairline),
        padding: const EdgeInsets.symmetric(
          horizontal: OCSpace.lg,
          vertical: OCSpace.sm,
        ),
        minimumSize: const Size(0, OCSpace.tapTarget),
        shape: const StadiumBorder(),
        textStyle: OCTypography.button.copyWith(fontSize: 13),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cs.onSurface,
        padding: const EdgeInsets.symmetric(
          horizontal: OCSpace.md,
          vertical: OCSpace.sm,
        ),
        minimumSize: const Size(0, OCSpace.tapTarget),
        shape: const StadiumBorder(),
        textStyle: OCTypography.button.copyWith(fontSize: 13),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: cs.onSurface,
        minimumSize: const Size(OCSpace.tapTarget, OCSpace.tapTarget),
      ),
    ),

    // --- Chips ----------------------------------------------------------
    chipTheme: ChipThemeData(
      backgroundColor: cs.surfaceContainerHigh,
      selectedColor: OCColors.orangeTint,
      disabledColor: cs.surfaceContainerHigh.withValues(alpha: 0.5),
      labelStyle: OCTypography.caption.withColor(cs.onSurface),
      secondaryLabelStyle: OCTypography.bodyStrong.withColor(
        OCColors.orangeInk,
      ),
      checkmarkColor: OCColors.orangeInk,
      iconTheme: IconThemeData(color: cs.onSurfaceVariant, size: 16),
      padding: const EdgeInsets.symmetric(
        horizontal: OCSpace.sm,
        vertical: OCSpace.xs,
      ),
      shape: const StadiumBorder(),
      side: BorderSide.none,
      brightness: cs.brightness,
    ),

    // --- Dividers -------------------------------------------------------
    dividerTheme: DividerThemeData(
      color: isLight ? OCColors.divider : cs.outlineVariant,
      thickness: 1,
      space: OCSpace.sm,
      indent: 0,
      endIndent: 0,
    ),

    // --- Lists ----------------------------------------------------------
    listTileTheme: ListTileThemeData(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: OCSpace.screenX,
        vertical: OCSpace.xs,
      ),
      titleTextStyle: OCTypography.body.withColor(cs.onSurface),
      subtitleTextStyle: OCTypography.micro.withColor(cs.onSurfaceVariant),
      leadingAndTrailingTextStyle: OCTypography.caption.withColor(
        cs.onSurfaceVariant,
      ),
      iconColor: cs.onSurfaceVariant,
      textColor: cs.onSurface,
      selectedTileColor: OCColors.orangeTint.withValues(alpha: 0.6),
      selectedColor: cs.onSurface,
      minVerticalPadding: OCSpace.sm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OCRadius.inner),
      ),
    ),

    // --- Dialogs / sheets -----------------------------------------------
    dialogTheme: DialogThemeData(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: OCTypography.h3.withColor(cs.onSurface),
      contentTextStyle: OCTypography.body.withColor(cs.onSurfaceVariant),
      insetPadding: const EdgeInsets.all(OCSpace.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OCRadius.card),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(OCRadius.sheet),
        ),
      ),
      modalBarrierColor: cs.shadow.withValues(alpha: 0.35),
      dragHandleColor: cs.outlineVariant,
      showDragHandle: true,
    ),

    // --- Navigation -----------------------------------------------------
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 66,
      indicatorColor: OCColors.orangeTint,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? OCTypography.micro.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              )
            : OCTypography.micro.withColor(cs.onSurfaceVariant),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? OCColors.orangeInk
              : cs.onSurfaceVariant,
          size: 22,
        ),
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(OCRadius.card),
        ),
      ),
    ),

    // --- Tooltips / snackbars -------------------------------------------
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: cs.inverseSurface,
        borderRadius: BorderRadius.circular(OCRadius.xs),
      ),
      textStyle: OCTypography.caption.withColor(cs.onInverseSurface),
      padding: const EdgeInsets.symmetric(
        horizontal: OCSpace.sm,
        vertical: OCSpace.xs,
      ),
      verticalOffset: 8,
      preferBelow: true,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cs.inverseSurface,
      contentTextStyle: OCTypography.body.withColor(cs.onInverseSurface),
      actionTextColor: OCColors.orange,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OCRadius.inner),
      ),
      elevation: 2,
    ),

    // --- Progress --------------------------------------------------------
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: OCColors.orange,
      linearTrackColor: const Color(0xFFFFF1D6),
      circularTrackColor: const Color(0xFFFFF1D6),
    ),

    // --- Selection -------------------------------------------------------
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: cs.onSurface,
      selectionColor: OCColors.purple.withValues(alpha: 0.25),
      selectionHandleColor: OCColors.purple,
    ),

    visualDensity: VisualDensity.standard,
  );
}
