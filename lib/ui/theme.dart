// Design tokens — "Playful Soft-UI" (design-system.json v1.0.0).
// Single source of truth for colour, type, spacing, shape, elevation and motion.
// Nothing in the app should hard-code a colour, radius, shadow or text size.

import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

/// Semantic colour roles used across the app.
/// All widgets should reference these, never hard-code colours.
class OCColors {
  // --- the single brand accent (design/clean-chat-ui.html) ------------
  /// Accent orange. Used by the chat redesign for the send button, the
  /// running tool dot and the active bottom-nav tab.
  static const acc = Color(0xFFF26A1B);
  static const accInk = Color(0xFFB9460C);
  static const accSoft = Color(0xFFFFF0E6);

  // --- neutrals -------------------------------------------------------
  static const canvas = Color(0xFFF0F0F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSubtle = Color(0xFFF6F6FA);
  static const surfaceMuted = Color(0xFFEFEFF5);
  static const borderHairline = Color(0xFFECECF2);
  static const divider = Color(0xFFF0F0F4);
  // Contrast on the canvas (#F0F0F7) and on white:
  // textPrimary 20.1:1 · textSecondary 6.3:1 · textTertiary 4.7:1 — all >= 4.5:1.
  static const textPrimary = Color(0xFF0D0D12);
  static const textSecondary = Color(0xFF565667);
  static const textTertiary = Color(0xFF6B6B7B);
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
  static const yellowInk = Color(0xFF854D0E);

  static const blue = Color(0xFF4C9AFF);
  static const blueSky = Color(0xFFBFE3FF);
  static const blueTint = Color(0xFFE6F2FF);
  static const blueInk = Color(0xFF1D4ED8);

  static const green = Color(0xFF34C759);
  static const greenTint = Color(0xFFE4F8E8);
  static const greenInk = Color(0xFF166534);

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
  static const toggleOn = orangeDeep;
  static const toggleOff = Color(0xFFD9D9E3);

  /// Tonal steps of the single secondary hue, used for tracks and fills.
  static const orangeWash = Color(0xFFFFF7EC);

  // --- code surfaces --------------------------------------------------
  static const codeBg = surfaceSubtle;
  static const codeBorder = borderHairline;

  // --- aliases kept so existing call sites keep compiling -------------
  static const accent = ctaSolid;
  static const accentHover = Color(0xFF2A2A35);
  static const accentSoft = orange;
  static const error = danger;
  static const textOnAccent = textInverse;
  static const textMuted = textSecondary;
  static const surfaceLow = surfaceSubtle;
  static const surfaceHigh = surfaceMuted;
  static const surfaceHighest = surfaceMuted;
  static const border = borderHairline;
  static const borderFocus = orange;
  static const selection = orange;
}

/// Brightness-aware palette taken straight from the visual reference
/// (`design/clean-chat-ui.html`). [OCColors] is a set of compile-time light
/// constants, so anything that must survive a dark theme reads from here
/// instead.
///
/// ```
/// :root                 {--bg:#f4f3f1;--card:#fff;--ink:#1c1b1a;--mute:#847f78;
///                        --line:#e7e4df;--acc:#f26a1b;--accink:#b9460c;
///                        --accsoft:#fff0e6;--ok:#2f9e44;--err:#c92a2a;
///                        --errsoft:#fdecec;--code:#26241f}
/// prefers-color-scheme  {--bg:#161517;--card:#212024;--ink:#f2efeb;--mute:#8e8993;
///                         --line:#333138;--accsoft:#3b2616;--accink:#ff9a5c;
///                         --errsoft:#3a1c1c;--code:#0f0e10}
/// ```
class OCTokens extends ThemeExtension<OCTokens> {
  const OCTokens({
    required this.bg,
    required this.card,
    required this.ink,
    required this.mute,
    required this.line,
    required this.acc,
    required this.accInk,
    required this.accSoft,
    required this.ok,
    required this.err,
    required this.errSoft,
    required this.code,
    required this.codeInk,
  });

  /// Screen background.
  final Color bg;

  /// Raised surfaces: composer box, suggestion cards, bottom sheet, nav bar.
  final Color card;

  /// Primary text.
  final Color ink;

  /// Secondary text (status line, timestamps, tool subtitles).
  final Color mute;

  /// Hairlines and the tool-timeline rail.
  final Color line;

  /// Accent fill (send button, running dot, active tab).
  final Color acc;

  /// Accent text/icon colour that stays readable on [accSoft] or on [card].
  final Color accInk;

  /// Tinted accent background (model pill, selected nav tab).
  final Color accSoft;

  /// "Tool finished" green.
  final Color ok;

  /// Failure red.
  final Color err;

  /// Tinted failure background.
  final Color errSoft;

  /// Terminal / tool-output surface. Always dark in both themes.
  final Color code;

  /// Foreground on [code].
  final Color codeInk;

  static const light = OCTokens(
    bg: Color(0xFFF4F3F1),
    card: Color(0xFFFFFFFF),
    ink: Color(0xFF1C1B1A),
    mute: Color(0xFF847F78),
    line: Color(0xFFE7E4DF),
    acc: OCColors.acc,
    accInk: Color(0xFFB9460C),
    accSoft: Color(0xFFFFF0E6),
    ok: Color(0xFF2F9E44),
    err: Color(0xFFC92A2A),
    errSoft: Color(0xFFFDECEC),
    code: Color(0xFF26241F),
    codeInk: Color(0xFFE9E5DD),
  );

  static const dark = OCTokens(
    bg: Color(0xFF161517),
    card: Color(0xFF212024),
    ink: Color(0xFFF2EFEB),
    mute: Color(0xFF8E8993),
    line: Color(0xFF333138),
    acc: OCColors.acc,
    accInk: Color(0xFFFF9A5C),
    accSoft: Color(0xFF3B2616),
    ok: Color(0xFF51CF66),
    err: Color(0xFFFF8787),
    errSoft: Color(0xFF3A1C1C),
    code: Color(0xFF0F0E10),
    codeInk: Color(0xFFE9E5DD),
  );

  /// Never throws: a missing extension falls back to the palette that matches
  /// the ambient brightness.
  static OCTokens of(BuildContext context) {
    final t = Theme.of(context);
    return t.extension<OCTokens>() ??
        (t.brightness == Brightness.dark ? dark : light);
  }

  bool get isDark => ink.computeLuminance() > 0.5;

  @override
  OCTokens copyWith({
    Color? bg,
    Color? card,
    Color? ink,
    Color? mute,
    Color? line,
    Color? acc,
    Color? accInk,
    Color? accSoft,
    Color? ok,
    Color? err,
    Color? errSoft,
    Color? code,
    Color? codeInk,
  }) => OCTokens(
    bg: bg ?? this.bg,
    card: card ?? this.card,
    ink: ink ?? this.ink,
    mute: mute ?? this.mute,
    line: line ?? this.line,
    acc: acc ?? this.acc,
    accInk: accInk ?? this.accInk,
    accSoft: accSoft ?? this.accSoft,
    ok: ok ?? this.ok,
    err: err ?? this.err,
    errSoft: errSoft ?? this.errSoft,
    code: code ?? this.code,
    codeInk: codeInk ?? this.codeInk,
  );

  @override
  OCTokens lerp(covariant OCTokens? other, double t) {
    if (other == null || t == 0) return this;
    if (t == 1) return other;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return OCTokens(
      bg: c(bg, other.bg),
      card: c(card, other.card),
      ink: c(ink, other.ink),
      mute: c(mute, other.mute),
      line: c(line, other.line),
      acc: c(acc, other.acc),
      accInk: c(accInk, other.accInk),
      accSoft: c(accSoft, other.accSoft),
      ok: c(ok, other.ok),
      err: c(err, other.err),
      errSoft: c(errSoft, other.errSoft),
      code: c(code, other.code),
      codeInk: c(codeInk, other.codeInk),
    );
  }
}

/// Shortcut so widgets read `context.oc.ink` instead of digging for the
/// extension by hand.
extension OCTokensX on BuildContext {
  OCTokens get oc => OCTokens.of(this);
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

  /// Accessibility: every tappable element is at least 48x48dp.
  static const tapTarget = 48.0;

  /// Minimum gap between two tappable elements.
  static const tapGap = 8.0;
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

/// Light theme — the design system's default. Pale warm-grey canvas, matching
/// the visual reference (`--bg:#f4f3f1`).
ThemeData buildLightTheme() {
  const cs = ColorScheme(
    brightness: Brightness.light,
    // One primary colour (ink) + one tonal secondary (orange family).
    primary: OCColors.ctaSolid,
    onPrimary: OCColors.textInverse,
    primaryContainer: Color(0xFFFAF9F8),
    onPrimaryContainer: OCColors.textPrimary,
    secondary: OCColors.acc,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: OCColors.accSoft,
    onSecondaryContainer: Color(0xFFB9460C),
    tertiary: OCColors.acc,
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFE6D2),
    onTertiaryContainer: Color(0xFFB9460C),
    error: OCTokens.light.err,
    onError: OCColors.textInverse,
    errorContainer: OCTokens.light.errSoft,
    onErrorContainer: OCTokens.light.err,
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1C1B1A),
    onSurfaceVariant: Color(0xFF847F78),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFAF9F8),
    surfaceContainer: OCTokens.light.bg,
    surfaceContainerHigh: Color(0xFFFAF9F8),
    surfaceContainerHighest: Color(0xFFEFEDE9),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceDim: Color(0xFFEAE7E2),
    outline: Color(0xFF847F78),
    outlineVariant: OCTokens.light.line,
    shadow: const Color(0xFF1C1B1A),
    scrim: const Color(0xFF1C1B1A),
    inverseSurface: Color(0xFF1C1B1A),
    onInverseSurface: Color(0xFFFFFFFF),
    inversePrimary: Color(0xFFF4F3F1),
    surfaceTint: Colors.transparent,
  );
  return _baseTheme(cs);
}

/// Semantic aliases so widgets read one vocabulary instead of raw colours.
extension OCColorSchemeX on ColorScheme {
  /// Tonal surface used behind selected rows, chips and menus.
  Color get tonalSurface => secondaryContainer;

  /// Text-safe colour for content placed on [tonalSurface].
  Color get onTonalSurface => onSecondaryContainer;

  /// Hairline that separates stacked rows on a card surface.
  Color get hairline => outlineVariant;
}

/// Dark theme — the reference dark palette (`--bg:#161517`, `--card:#212024`).
/// Picked automatically when the OS is in dark mode.
ThemeData buildDarkTheme() {
  const cs = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF2EFEB),
    onPrimary: Color(0xFF161517),
    primaryContainer: Color(0xFF2B2A2E),
    onPrimaryContainer: Color(0xFFF2EFEB),
    secondary: OCColors.acc,
    onSecondary: Color(0xFF161517),
    secondaryContainer: Color(0xFF3B2616),
    onSecondaryContainer: Color(0xFFFF9A5C),
    tertiary: OCColors.acc,
    onTertiary: Color(0xFF161517),
    tertiaryContainer: Color(0xFF3B2616),
    onTertiaryContainer: Color(0xFFFF9A5C),
    error: OCTokens.dark.err,
    onError: Color(0xFF161517),
    errorContainer: Color(0xFF3A1C1C),
    onErrorContainer: Color(0xFFFF8787),
    surface: Color(0xFF161517),
    onSurface: Color(0xFFF2EFEB),
    onSurfaceVariant: Color(0xFF8E8993),
    surfaceContainerLowest: Color(0xFF100F11),
    surfaceContainerLow: Color(0xFF1B1A1C),
    surfaceContainer: Color(0xFF212024),
    surfaceContainerHigh: Color(0xFF262527),
    surfaceContainerHighest: Color(0xFF2E2D30),
    surfaceBright: Color(0xFF3A383C),
    surfaceDim: Color(0xFF0C0B0D),
    outline: Color(0xFF8E8993),
    outlineVariant: Color(0xFF333138),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFF2EFEB),
    onInverseSurface: Color(0xFF161517),
    inversePrimary: Color(0xFF262527),
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
    // The brightness-aware reference palette. Read it with `context.oc`.
    extensions: <ThemeExtension<dynamic>>[
      isLight ? OCTokens.light : OCTokens.dark,
    ],
    // Design system: the screen background is the canvas tint, cards sit on top of it.
    canvasColor: isLight ? OCTokens.light.bg : cs.surface,
    scaffoldBackgroundColor: isLight ? OCTokens.light.bg : cs.surface,
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
      // M3 destinations are already 48dp tall targets.
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
      actionTextColor: OCColors.orangeBright,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OCRadius.inner),
      ),
      elevation: 2,
    ),

    // --- Progress --------------------------------------------------------
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: OCColors.orangeDeep,
      linearTrackColor: OCColors.orangeTrack,
      circularTrackColor: OCColors.orangeTrack,
    ),

    // --- Selection -------------------------------------------------------
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: cs.onSurface,
      selectionColor: OCColors.orange.withValues(alpha: 0.25),
      selectionHandleColor: OCColors.orangeDeep,
    ),

    visualDensity: VisualDensity.standard,
  );
}
