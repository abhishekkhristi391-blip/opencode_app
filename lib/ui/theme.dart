// Design tokens — "Playful Soft-UI" (design-system.json v1.0.0).
// Single source of truth for colour, type, spacing, shape, elevation and motion.
// Nothing in the app should hard-code a colour, radius, shadow or text size.

import 'dart:ui' show FontFeature;

import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Semantic colour roles used across the app.
/// All widgets should reference these, never hard-code colours./// Compile-time palette.
///
/// This app is dark-only (see [buildAppTheme]), so these are the dark values.
/// They exist as `const`s only so the few widgets that cannot reach a
/// [BuildContext] can still read a token instead of writing a hex literal.
/// Anything inside a widget MUST use `context.oc`.
class OCColors {
  // --- surfaces (dark, darkest to lightest) ------------------------------
  /// Screen background.
  static const bg = Color(0xFF121214);

  /// Cards, list rows, sheets.
  static const surface = Color(0xFF1A1A1E);

  /// One step up: composer box, path bar, pressed rows, terminal input bar.
  static const surfaceElevated = Color(0xFF232328);

  /// Terminal viewport. Darker than [bg] on purpose - a terminal should read as
  /// a recessed well, not a card.
  static const terminalBg = Color(0xFF0B0B0D);

  /// Terminal foreground.
  static const terminalText = Color(0xFFD4D4D8);

  // --- lines --------------------------------------------------------------
  /// The only border colour in the app. 1dp, hairline.
  static const border = Color(0xFF2E2E34);

  // --- text ---------------------------------------------------------------
  /// Body, titles, anything the user is meant to read first.
  static const textPrimary = Color(0xFFF2F2F3);

  /// Supporting text: subtitles, timestamps, hints, inactive nav labels.
  /// 7.37:1 on [surface] - passes 4.5:1 comfortably.
  static const textSecondary = Color(0xFFA8A8B3);

  /// Tertiary: placeholders, disabled. 3.0:1 - decorative only, never load-bearing.
  static const textTertiary = Color(0xFF6E6E7A);

  // --- accent -------------------------------------------------------------
  /// The single accent. ONLY: the primary action, the active nav tab, and the
  /// selected state. Never a surface, never a border on an inert control.
  static const accent = Color(0xFFFF8A3D);

  /// Text/icon colour ON an accent fill. Dark, because the accent is light:
  /// 7.98:1.
  static const onAccent = Color(0xFF121214);

  /// 12% accent wash for selected rows. Never a solid peach fill - that is what
  /// made the Models and History tabs look like a light theme.
  static const accentSoft = Color(0x24FF8A3D);

  /// Border of a selected control.
  static const accentLine = Color(0x8CFF8A3D);

  // --- status -------------------------------------------------------------
  static const success = Color(0xFF34D399);
  static const error = Color(0xFFF87171);
  static const warning = Color(0xFFFBBF24);

  /// 12% washes for status backgrounds.
  static const successSoft = Color(0x2434D399);
  static const errorSoft = Color(0x24F87171);
  static const warningSoft = Color(0x24FBBF24);

  // --- code ---------------------------------------------------------------
  static const codeBg = terminalBg;
  static const codeInk = textSecondary;

  // --- terminal ANSI (dark, readable) -------------------------------------
  static const ansiBlack = Color(0xFF4B4B55);
  static const ansiRed = error;
  static const ansiGreen = success;
  static const ansiYellow = warning;
  static const ansiBlue = Color(0xFF60A5FA);
  static const ansiMagenta = Color(0xFFC084FC);
  static const ansiCyan = Color(0xFF22D3EE);
  static const ansiWhite = Color(0xFFE4E4E7);
  static const ansiBrightBlack = Color(0xFF71717A);

  // --- legacy aliases -----------------------------------------------------
  //
  // 221 call sites across 13 UI files still name these. They used to point at a
  // LIGHT palette, which is the actual root cause: `OCColors.surfaceSubtle` was
  // a near-white, so a card, a sheet or a text field asked for "surfaceSubtle"
  // and got white. Every name below now resolves to a dark value, so switching
  // the palette killed all 221 light surfaces at once instead of file by file.
  // New code reads `context.oc.*`; these exist so the conversion can be
  // incremental and so nothing has to be renamed in the same commit as its colour.
  static const canvas = bg;
  static const surfaceSubtle = surfaceElevated;
  static const surfaceMuted = surfaceElevated;
  static const surfaceHigh = surfaceElevated;
  static const surfaceHighest = surfaceElevated;
  static const surfaceLow = surface;
  static const borderHairline = border;
  static const divider = border;
  static const textInverse = bg;
  static const textOnAccent = onAccent;
  static const textMuted = textSecondary;
  static const ctaSolid = accent;
  static const ctaAlt = accent;
  static const toggleOn = accent;
  static const toggleOff = surfaceElevated;
  static const danger = error;
  static const codeBorder = border;
  static const selection = accent;

  // Status hues, dark-legible. Used for tool icons, diff sides and capability
  // chips - never for a surface.
  static const purple = Color(0xFFA78BFA);
  static const purpleSoft = Color(0xFFC4B5FD);
  static const purpleTint = Color(0xFF241F33);
  static const purpleInk = Color(0xFFC4B5FD);

  static const orange = accent;
  static const orangeDeep = Color(0xFFF97316);
  static const orangeBright = Color(0xFFFFA45C);
  static const orangeTrack = Color(0xFF4A2E1A);
  static const orangeTint = Color(0xFF2A1B10);
  static const orangeInk = accent;

  static const pink = Color(0xFFF472B6);
  static const pinkHot = Color(0xFFE879F9);
  static const pinkTint = Color(0xFF2E1B2A);
  static const pinkInk = Color(0xFFF9A8D4);

  static const yellow = warning;
  static const yellowSoft = Color(0xFFFDE68A);
  static const yellowTint = Color(0xFF2E2612);
  static const yellowInk = Color(0xFFFCD34D);

  static const blue = Color(0xFF60A5FA);
  static const blueSky = Color(0xFF93C5FD);
  static const blueTint = Color(0xFF16233A);
  static const blueInk = Color(0xFF93C5FD);

  static const green = success;
  static const greenTint = Color(0xFF10261F);
  static const greenInk = Color(0xFF6EE7B7);

  static const red = error;
  static const redTint = Color(0xFF2E1618);
  static const redInk = Color(0xFFFCA5A5);
}

/// Brightness-aware token set, read with `context.oc`.
///
/// ```
/// --bg #121214   --surface #1A1A1E   --surfaceElevated #232328
/// --border #2E2E34   --ink #F2F2F3   --mute #A8A8B3
/// --accent #FF8A3D   --success #34D399  --error #F87171  --warning #FBBF24
/// --terminal #0B0B0D   --terminalText #D4D4D8
/// ```
class OCTokens extends ThemeExtension<OCTokens> {
  const OCTokens({
    required this.bg,
    required this.card,
    required this.surfaceElevated,
    required this.ink,
    required this.mute,
    required this.faint,
    required this.line,
    required this.acc,
    required this.accInk,
    required this.accSoft,
    required this.accLine,
    required this.onAcc,
    required this.ok,
    required this.warn,
    required this.err,
    required this.okSoft,
    required this.errSoft,
    required this.warnSoft,
    required this.code,
    required this.codeInk,
    required this.terminalBg,
    required this.terminalInk,
  });

  /// Screen background.
  final Color bg;

  /// Cards, list rows, sheets.
  final Color card;

  /// One step above [card]: the composer, the path bar, the terminal input bar.
  ///
  /// Separate from [card] because the composer used to share the cards' fill, so
  /// the bottom of the chat looked like one flat slab with no input area.
  final Color surfaceElevated;

  /// Primary text.
  final Color ink;

  /// Secondary text.
  final Color mute;

  /// Tertiary text. Placeholders and disabled states only.
  final Color faint;

  /// The only border colour.
  final Color line;

  /// Accent fill.
  final Color acc;

  /// Accent that stays readable on [bg] / [card] (selected icon, active label).
  final Color accInk;

  /// Accent wash for selected rows.
  final Color accSoft;

  /// Border of a selected control.
  final Color accLine;

  /// Text on an accent fill.
  final Color onAcc;

  /// Success, warning and error, plus their washes.
  final Color ok, warn, err, okSoft, errSoft, warnSoft;

  /// Code block background and foreground.
  final Color code, codeInk;

  /// Terminal viewport and foreground.
  final Color terminalBg, terminalInk;

  static const dark = OCTokens(
    bg: OCColors.bg,
    card: OCColors.surface,
    surfaceElevated: OCColors.surfaceElevated,
    ink: OCColors.textPrimary,
    mute: OCColors.textSecondary,
    faint: OCColors.textTertiary,
    line: OCColors.border,
    acc: OCColors.accent,
    accInk: OCColors.accent,
    accSoft: OCColors.accentSoft,
    accLine: OCColors.accentLine,
    onAcc: OCColors.onAccent,
    ok: OCColors.success,
    warn: OCColors.warning,
    err: OCColors.error,
    okSoft: OCColors.successSoft,
    errSoft: OCColors.errorSoft,
    warnSoft: OCColors.warningSoft,
    code: OCColors.codeBg,
    codeInk: OCColors.codeInk,
    terminalBg: OCColors.terminalBg,
    terminalInk: OCColors.terminalText,
  );

  /// The app has one palette. Kept as an alias so a light theme can be added
  /// later without touching every call site.
  static const light = dark;

  static OCTokens of(BuildContext context) =>
      Theme.of(context).extension<OCTokens>() ?? dark;

  @override
  OCTokens copyWith({
    Color? bg,
    Color? card,
    Color? surfaceElevated,
    Color? ink,
    Color? mute,
    Color? faint,
    Color? line,
    Color? acc,
    Color? accInk,
    Color? accSoft,
    Color? accLine,
    Color? onAcc,
    Color? ok,
    Color? warn,
    Color? err,
    Color? okSoft,
    Color? errSoft,
    Color? warnSoft,
    Color? code,
    Color? codeInk,
    Color? terminalBg,
    Color? terminalInk,
  }) => OCTokens(
    bg: bg ?? this.bg,
    card: card ?? this.card,
    surfaceElevated: surfaceElevated ?? this.surfaceElevated,
    ink: ink ?? this.ink,
    mute: mute ?? this.mute,
    faint: faint ?? this.faint,
    line: line ?? this.line,
    acc: acc ?? this.acc,
    accInk: accInk ?? this.accInk,
    accSoft: accSoft ?? this.accSoft,
    accLine: accLine ?? this.accLine,
    onAcc: onAcc ?? this.onAcc,
    ok: ok ?? this.ok,
    warn: warn ?? this.warn,
    err: err ?? this.err,
    okSoft: okSoft ?? this.okSoft,
    errSoft: errSoft ?? this.errSoft,
    warnSoft: warnSoft ?? this.warnSoft,
    code: code ?? this.code,
    codeInk: codeInk ?? this.codeInk,
    terminalBg: terminalBg ?? this.terminalBg,
    terminalInk: terminalInk ?? this.terminalInk,
  );

  @override
  OCTokens lerp(covariant OCTokens? other, double k) {
    if (other == null || k == 0) return this;
    if (k == 1) return other;
    Color c(Color a, Color b) => Color.lerp(a, b, k)!;
    return OCTokens(
      bg: c(bg, other.bg),
      card: c(card, other.card),
      surfaceElevated: c(surfaceElevated, other.surfaceElevated),
      ink: c(ink, other.ink),
      mute: c(mute, other.mute),
      faint: c(faint, other.faint),
      line: c(line, other.line),
      acc: c(acc, other.acc),
      accInk: c(accInk, other.accInk),
      accSoft: c(accSoft, other.accSoft),
      accLine: c(accLine, other.accLine),
      onAcc: c(onAcc, other.onAcc),
      ok: c(ok, other.ok),
      warn: c(warn, other.warn),
      err: c(err, other.err),
      okSoft: c(okSoft, other.okSoft),
      errSoft: c(errSoft, other.errSoft),
      warnSoft: c(warnSoft, other.warnSoft),
      code: c(code, other.code),
      codeInk: c(codeInk, other.codeInk),
      terminalBg: c(terminalBg, other.terminalBg),
      terminalInk: c(terminalInk, other.terminalInk),
    );
  }
}

// ---------------------------------------------------------------------------
// Compatibility shims.
//
// These predate the dark redesign and are still referenced by primitives.dart.
// They are re-declared here, pointed at dark tokens, so no call site has to
// change and no light value survives.
// ---------------------------------------------------------------------------

class OCShadow {
  const OCShadow._();
  static const none = <BoxShadow>[];

  /// Cards: a hairline, not a drop shadow. A shadow on a dark surface reads as
  /// a smudge because there is no lighter background to lift it off.
  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const cardHover = <BoxShadow>[
    BoxShadow(color: Color(0x1F000000), offset: Offset(0, 2), blurRadius: 6),
  ];

  static const floatingCta = <BoxShadow>[
    BoxShadow(color: Color(0x4D000000), offset: Offset(0, 4), blurRadius: 12),
  ];

  static const coloredCtaGlow = <BoxShadow>[
    BoxShadow(color: Color(0x33FF8A3D), offset: Offset(0, 2), blurRadius: 8),
  ];

  static const segmentedActive = <BoxShadow>[];
  static const toggleThumb = <BoxShadow>[
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 2),
  ];
}

class OCGradient {
  const OCGradient._();

  /// Accent fills only. The pastel ones are gone: a soft peach gradient is
  /// exactly what made the primary button read as a light-theme surface.
  static const ctaOrangeSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8A3D), Color(0xFFFFA45C)],
  );

  static const ctaSunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8A3D), Color(0xFFFF6B35)],
  );

  static const heroSky = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF232328), Color(0xFF1A1A1E)],
  );

  static const heroPastelBlend = heroSky;
  static const progressWarm = LinearGradient(
    colors: [Color(0xFFFF8A3D), Color(0xFF34D399)],
  );
}

/// Shortcut: `context.oc.ink` instead of digging out the extension.
extension OCTokensX on BuildContext {
  OCTokens get oc => OCTokens.of(this);
}

/// The 4/8/12/16/24/32 scale. Nothing else.
class OCSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// The scale, in order. For pickers and chips.
  static const scale = [xs, sm, md, lg, xl, xxl];

  /// THE horizontal screen padding. 16dp, on every screen, without exception.
  ///
  /// The app had three different insets at once (header 18, content 18, composer
  /// 12, and 16 in the primitives), so no two things on a screen lined up. This
  /// constant plus [screenX] as its legacy alias is the only inset in the app.
  static const screenX = 16.0;
  static const screenGutter = screenX;

  /// Vertical gap under the app bar, before a list starts.
  static const sectionTop = 8.0;

  /// Card padding.
  static const cardPad = 16.0;

  /// Gap above the bottom nav.
  static const navGap = 8.0;

  /// Legacy 6/10/14 steps. Kept so nothing has to be retuned in one pass; the
  /// redesign does not introduce them.
  static const xxs = 6.0;
  static const xxxl = 40.0;
  static const ctaBottom = 24.0;

  /// Accessibility: every tappable element is at least 48x48.
  static const tapTarget = 48.0;

  /// Minimum gap between two tappable elements.
  static const tapGap = 8.0;
}

/// Squircle-and-pills shape language. No sharp corners.
class OCRadius {
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const full = 9999.0;

  // --- named roles --------------------------------------------------------
  /// Cards and list rows. 12dp.
  static const card = 12.0;

  /// Compact rows: suggestion cards, file rows, session rows.
  static const row = 12.0;

  /// Alias for [row]; the chat empty state's cards use it.
  static const suggestion = row;

  /// The composer field.
  static const composer = 20.0;

  /// Top corners of a bottom sheet.
  static const sheet = 20.0;

  /// Icon tiles, chips.
  static const tile = 12.0;

  /// Pills: status pill, nav indicator, jump-to-latest.
  static const pill = full;

  /// Inner cells kept for existing call sites.
  static const inner = 16.0;

  static const avatarRadius = Radius.circular(full);
}

/// Springy, playful, quick.
class OCMotion {
  static const pressScale = 0.97; // small controls
  static const micro = Duration(milliseconds: 120);
  static const quick = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 400);

  /// Press feedback for large surfaces: cards, list rows, the composer box.
  ///
  /// Shallower than [pressScale] on purpose - 0.97 on a 64dp row shifts its edges
  /// ~2dp and the card reads as a glitch rather than a response.
  static const pressScaleSoft = 0.98;

  /// The reconnecting pulse.
  static const pulse = Duration(milliseconds: 1100);

  /// The 2dp indeterminate progress line under the header.
  static const progress = Duration(milliseconds: 1600);

  /// Default easing for taps and row highlights.
  static const curve = Curves.easeOutCubic;
  static const curveDecel = Curves.easeOut;
  static const curveEmphatic = Curves.easeOutBack;

  /// Legacy aliases.
  static const base = normal;
  static const standard = normal;
  static const emphasis = slow;
}

/// Typography - Plus Jakarta Sans with Poppins / Inter fallbacks.
class OCTypography {
  static const _uiFamily = 'PlusJakartaSans';
  static const _fallback = ['Poppins', 'Inter', 'Roboto'];

  /// Code, paths, commands, terminal output.
  ///
  /// `monospace` is Flutter's generic family: it resolves to Roboto Mono on
  /// Android and the platform's own mono elsewhere, so it is already the
  /// second choice named in the brief. Shipping JetBrains Mono proper would mean
  /// adding a ~200 KB .ttf under `assets/fonts/` and one pubspec entry - no new
  /// dependency, just a binary. Left as `monospace` until that file exists;
  /// swapping this one constant upgrades every mono call site at once.
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

  // --- the four steps the brief defines ----------------------------------

  /// 28 / 34 / 600 - screen headline. One per screen, at most.
  static final headline = _sans(
    size: 28,
    weight: FontWeight.w600,
    height: 34 / 28,
    spacing: -0.5,
  );

  /// 16 / 22 / 500 - row titles, section headings.
  static final title = _sans(
    size: 16,
    weight: FontWeight.w500,
    height: 22 / 16,
  );

  /// 15 / 22 / 400 - body copy and message text.
  static final body = _sans(size: 15, weight: FontWeight.w400, height: 22 / 15);

  /// 12 / 16 - captions: timestamps, meta, hints.
  static final caption = _sans(
    size: 12,
    weight: FontWeight.w400,
    height: 16 / 12,
  );

  // --- weights the screens need on top of the four steps -----------------

  /// 15 / 600 - buttons.
  static final button = _sans(size: 15, weight: FontWeight.w600, height: 1.2);

  /// 13 / 18 / 500 - chip and pill labels.
  static final meta = _sans(size: 13, weight: FontWeight.w500, height: 18 / 13);

  /// 13 / 18 / 600 - selected chip labels.
  static final metaStrong = _sans(
    size: 13,
    weight: FontWeight.w600,
    height: 18 / 13,
  );

  /// 15 / 600 - message sender label.
  static final label = _sans(size: 15, weight: FontWeight.w600, height: 1.2);

  /// Tabular figures for counts, sizes and durations.
  static TextStyle numeric({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) => _sans(
    size: size,
    weight: weight,
    height: 1.2,
    color: color,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  // --- mono ---------------------------------------------------------------

  static TextStyle mono({
    Color? color,
    double size = 13,
    double height = 1.45,
  }) => TextStyle(
    fontFamily: _monoFamily,
    fontFamilyFallback: const ['RobotoMono', 'monospace', 'Menlo', 'Consolas'],
    fontSize: size,
    height: height,
    color: color,
  );

  static TextStyle monoSmall({Color? color}) =>
      mono(color: color, size: 12, height: 1.4);

  static TextStyle monoLarge({Color? color}) =>
      mono(color: color, size: 14, height: 1.5);

  // --- legacy aliases, so existing call sites keep compiling --------------
  static TextStyle get h1 => headline;
  static TextStyle get h2 => title;
  static TextStyle get h3 => title;
  static TextStyle get displayXl => headline;
  static TextStyle get displayAmount => headline;
  static TextStyle get displayLarge => headline;
  static TextStyle get bodyLarge => body;
  static TextStyle get bodyStrong =>
      _sans(size: 15, weight: FontWeight.w600, height: 22 / 15);
  static TextStyle get bodySmall => caption;
  static TextStyle get micro => caption;
  static TextStyle get heroTitle => headline;
  static TextStyle get subtitle => caption;
  static TextStyle get overline => caption;
}

extension _TextStyleExt on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
}

/// Light theme — the design system's default. Pale warm-grey canvas, matching
/// the visual reference (`--bg:#f4f3f1`).
/// The app has exactly one theme: dark.
///
/// Previously this returned [buildLightTheme] when the OS was light, which is
/// how white cards, a white sheet and a peach selection ended up inside an app
/// whose own palette was dark: every light surface in the app was a system
/// surface leaking through [buildLightTheme]. There is no longer a light branch
/// to leak.
ThemeData buildAppTheme() => _buildTheme();

ThemeData _buildTheme() {
  const t = OCTokens.dark;
  const cs = ColorScheme(
    brightness: Brightness.dark,
    primary: OCColors.accent,
    onPrimary: OCColors.onAccent,
    primaryContainer: OCColors.accentSoft,
    onPrimaryContainer: OCColors.accent,
    secondary: OCColors.textSecondary,
    onSecondary: OCColors.bg,
    error: OCColors.error,
    onError: OCColors.bg,
    errorContainer: OCColors.errorSoft,
    onErrorContainer: OCColors.error,
    surface: OCColors.bg,
    onSurface: OCColors.textPrimary,
    onSurfaceVariant: OCColors.textSecondary,
    surfaceContainerHighest: OCColors.surface,
    outline: OCColors.border,
    outlineVariant: OCColors.border,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OCRadius.card),
        side: BorderSide(color: t.line),
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
            side: BorderSide(color: t.line),
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
        side: BorderSide(color: t.line),
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
      actionTextColor: OCColors.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(OCRadius.card),
        side: BorderSide(color: t.line),
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
      focusedBorder: _fieldBorder(OCColors.accent, width: 2),
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
      color: OCColors.accent,
      linearTrackColor: Colors.transparent,
      circularTrackColor: Colors.transparent,
    ),
    // One scrollbar for the whole app: right edge, 3dp, muted, fades out when
    // idle. Nothing else in the app paints a bar. `thumbVisibility: false` means
    // it can only appear in response to a scroll or a drag, so a list that does
    // not overflow can never show one - which is the whole point.
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.dragged) ? OCColors.accent : t.mute,
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
      borderRadius: BorderRadius.circular(OCRadius.row),
      borderSide: BorderSide(color: color, width: width),
    );

TextTheme _textTheme(OCTokens t) => TextTheme(
  displayLarge: OCTypography.headline.copyWith(color: t.ink),
  displayMedium: OCTypography.headline.copyWith(color: t.ink),
  displaySmall: OCTypography.headline.copyWith(color: t.ink),
  headlineMedium: OCTypography.headline.copyWith(color: t.ink),
  headlineSmall: OCTypography.title.copyWith(color: t.ink),
  titleLarge: OCTypography.title.copyWith(color: t.ink),
  titleMedium: OCTypography.title.copyWith(color: t.ink),
  titleSmall: OCTypography.meta.copyWith(color: t.ink),
  bodyLarge: OCTypography.body.copyWith(color: t.ink),
  bodyMedium: OCTypography.body.copyWith(color: t.ink),
  bodySmall: OCTypography.caption.copyWith(color: t.mute),
  labelLarge: OCTypography.button.copyWith(color: t.ink),
  labelMedium: OCTypography.meta.copyWith(color: t.ink),
  labelSmall: OCTypography.caption.copyWith(color: t.mute),
);
