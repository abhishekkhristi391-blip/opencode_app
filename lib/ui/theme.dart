// Design tokens — "Playful Soft-UI" (design-system.json v1.0.0).
// Single source of truth for colour, type, spacing, shape, elevation and motion.
// Nothing in the app should hard-code a colour, radius, shadow or text size.

import 'dart:ui' show FontFeature, FontVariation;

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
  // --- surfaces (Material 3 warm neutral, darkest to lightest) -------------
  //
  // Private ladder. Public names alias it, so a name can never shadow the step
  // it points at (`surfaceHighest = surfaceHighest` is not a legal const).
  static const _lowest = Color(0xFF0F0E0D);
  static const _low = Color(0xFF1C1B1A);
  static const _base = Color(0xFF201F1E);
  static const _high = Color(0xFF2B2A29);
  static const _highest = Color(0xFF363433);

  /// Screen background - `--bg`, M3 `surface`.
  static const bg = Color(0xFF141312);

  /// `surface-container-low` - cards, list rows, sheets, drawer, group fill.
  static const surface = _low;

  /// `surface-container` - the composer box, tool blocks, one step above
  /// [surface] so the bottom of the chat reads as an input area, not a slab.
  static const surfaceElevated = _base;

  /// `surface-container-high` - pressed rows, selected fill, active segments.
  static const surfaceHigh = _high;

  /// `surface-container-highest` - chips, segment rails, inactive pills.
  static const surfaceHighest = _highest;

  /// `surface-container-lowest` - the deepest well.
  static const surfaceLowest = _lowest;

  /// `surface-variant`: used where a M3 slot needs a distinct 5th step.
  static const surfaceVariant = _highest;

  /// `surface-bright`.
  static const surfaceBright = Color(0xFF3A3938);

  /// Terminal viewport. The design draws the terminal window as
  /// `container-low`; the code blocks inside chat sit one step deeper.
  static const terminalBg = _low;

  /// Terminal foreground - M3 `on-surface`.
  static const terminalText = Color(0xFFE6E2DF);

  // --- lines --------------------------------------------------------------
  /// M3 `outline-variant`. The only border colour in the app. 1dp, hairline.
  static const border = Color(0xFF474741);

  /// M3 `outline` - placeholders and strong dividers.
  static const borderStrong = Color(0xFF919189);

  // --- text ---------------------------------------------------------------
  /// Body, titles, anything the user is meant to read first - M3 `on-surface`.
  static const textPrimary = Color(0xFFE6E2DF);

  /// Supporting text - M3 `on-surface-variant`.
  static const textSecondary = Color(0xFFC8C7BE);

  /// Tertiary: placeholders, inactive rows - M3 `outline`.
  static const textTertiary = Color(0xFF919189);

  /// Quaternary: decorative rules, disabled glyphs - M3 `outline-variant`.
  static const textFaint = Color(0xFF474741);

  // --- accent -------------------------------------------------------------
  // Two accent roles, deliberately separated:
  //   terracotta (`accent`) = SELECTED / ACTIVE / warm highlight
  //   white     (`cta`)    = the filled primary action
  // The design has no orange left in it, and `#FF8A3D` was both roles at once,
  // which is why every button in the app was the same colour as every
  // selected tab.
  /// M3 `secondary` - the terracotta accent. Selected state, active tab,
  /// warm highlight, never a large surface.
  static const accent = Color(0xFFFFB59E);

  /// Text/icon on an [accent] fill - M3 `on-secondary`. 8.0:1.
  static const onAccent = Color(0xFF5C1902);

  /// 14% accent wash for selected rows. Never a solid terracotta fill - that
  /// is what used to make a selected row look like a light-theme surface.
  static const accentSoft = Color(0x24FFB59E);

  /// Border of a selected control.
  static const accentLine = Color(0x8CFFB59E);

  /// M3 `primary` - the filled primary action (send button, primary CTA).
  static const cta = Color(0xFFFFFFFF);

  /// Label on a [cta] fill - M3 `on-primary`.
  static const onCta = Color(0xFF30312C);

  /// 14% white wash: ghost rows, code badges on light fills.
  static const ctaSoft = Color(0x24FFFFFF);

  /// M3 `secondary-container` - the secondary button fill.
  static const secondary = Color(0xFF7D3117);

  /// Label on a [secondary] fill - M3 `on-secondary-container`.
  static const onSecondary = Color(0xFFFFA082);

  /// M3 `tertiary` - the design's cool blue, used for file-kind badges.
  static const tertiary = Color(0xFF7FB2F0);

  /// Label on a [tertiary] fill - M3 `on-tertiary-container`.
  static const onTertiary = Color(0xFF00325A);

  /// The design's `blue-900/50` chip wash.
  static const deep = Color(0xFF22303F);

  // --- status -------------------------------------------------------------
  static const success = Color(0xFF7BB07A);
  static const error = Color(0xFFE07A6B);
  static const warning = Color(0xFFE0A85A);

  /// Opaque washes, as the design draws them (`bg-green-900/40` and friends).
  /// Alpha washes over a warm neutral go muddy, so these are real values.
  static const successSoft = Color(0xFF1B2C1D);
  static const errorSoft = Color(0xFF2D1F1D);
  static const warningSoft = Color(0xFF33291A);

  /// Lighter status inks for text and icons. [errorInk] is M3 `error`.
  static const successInk = Color(0xFF9CC48A);
  static const errorInk = Color(0xFFFFB4AB);
  static const warningInk = Color(0xFFF0C078);

  // --- code ---------------------------------------------------------------
  /// `surface-container-lowest` - one step below the canvas, so a code block
  /// reads as a well rather than a card.
  static const codeBg = _lowest;
  static const codeInk = Color(0xFFC8C7BE);

  // --- terminal ANSI (dark, readable) -------------------------------------
  static const ansiBlack = Color(0xFF474741);
  static const ansiRed = error;
  static const ansiGreen = success;
  static const ansiYellow = warning;
  static const ansiBlue = tertiary;
  static const ansiMagenta = Color(0xFFC89BD8);
  static const ansiCyan = Color(0xFF6EC5C5);
  static const ansiWhite = Color(0xFFE6E2DF);
  static const ansiBrightBlack = Color(0xFF919189);

  // --- legacy aliases -----------------------------------------------------
  //
  // 221 call sites across 13 UI files still name these. They used to point at a
  // LIGHT palette, which is the actual root cause: `OCColors.surfaceSubtle` was
  // a near-white, so a card, a sheet or a text field asked for "surfaceSubtle"
  // and got white. Every name below now resolves to a warm dark value, so the
  // palette swap changed all 221 surfaces at once instead of file by file.
  // New code reads `context.oc.*`; these exist so the conversion can be
  // incremental and so nothing has to be renamed in the same commit as its colour.
  static const canvas = bg;
  static const surfaceSubtle = surfaceElevated;
  static const surfaceMuted = surfaceHigh;
  static const surfaceLow = surface;
  static const borderHairline = border;
  static const divider = border;
  static const textInverse = bg;
  static const textOnAccent = onAccent;
  static const textMuted = textSecondary;
  static const ctaSolid = cta;
  static const ctaAlt = secondary;
  static const toggleOn = cta;
  static const toggleOff = surface;
  static const danger = error;
  static const codeBorder = border;
  static const selection = accent;

  // Status hues, dark-legible. Used for tool icons, diff sides and capability
  // chips - never for a surface. Only green, red and blue are in the design;
  // the rest are warm-shifted to match it rather than left as raw Tailwind.
  static const purple = Color(0xFFB39BC4);
  static const purpleSoft = Color(0xFFD8CBEC);
  static const purpleTint = Color(0xFF26202F);
  static const purpleInk = Color(0xFFD8CBEC);

  static const orange = accent;
  static const orangeDeep = secondary;
  static const orangeBright = Color(0xFFFFDBD0);
  static const orangeTrack = _highest;
  static const orangeTint = surfaceHigh;
  static const orangeInk = accent;

  static const pink = Color(0xFFDDA0B4);
  static const pinkHot = Color(0xFFE9AEC0);
  static const pinkTint = Color(0xFF2E1F24);
  static const pinkInk = Color(0xFFF0C4D2);

  static const yellow = warning;
  static const yellowSoft = warningInk;
  static const yellowTint = warningSoft;
  static const yellowInk = warningInk;

  static const blue = tertiary;
  static const blueSky = Color(0xFFBFDBFE);
  static const blueTint = deep;
  static const blueInk = tertiary;

  static const green = success;
  static const greenTint = successSoft;
  static const greenInk = successInk;

  static const red = error;
  static const redTint = errorSoft;
  static const redInk = error;
}

/// Brightness-aware token set, read with `context.oc`.
///
/// ```
/// --bg #141312   --card #1C1B1A   --surfaceElevated #201F1E
/// --line #474741   --ink #E6E2DF   --mute #C8C7BE   --faint #919189
/// --cta #FFFFFF   --acc #FFB59E   --secondary #7D3117   --tertiary #7FB2F0
/// --ok #7BB07A   --err #E07A6B   --warn #E0A85A
/// --code #0F0E0D   --terminal #1C1B1A   --terminalInk #E6E2DF
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
    required this.cta,
    required this.onCta,
    required this.ctaSoft,
    required this.tertiary,
    required this.onTertiary,
    required this.deep,
    required this.lineStrong,
    required this.okInk,
    required this.errInk,
    required this.warnInk,
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

  /// The filled primary action (white) and the label on it. Deliberately NOT
  /// [acc]: terracotta is the selected/active hue, white is the primary button.
  final Color cta, onCta;

  /// 14% white wash - ghost rows, badges on light fills.
  final Color ctaSoft;

  /// The design's cool blue: file-kind badges and the `tertiary` role.
  final Color tertiary, onTertiary, deep;

  /// M3 `outline` - a divider that must read as a line, not a hint.
  final Color lineStrong;

  /// Lighter status inks for text and icons, where [ok]/[err]/[warn] are too
  /// heavy to sit on `on-surface`.
  final Color okInk, errInk, warnInk;

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
    cta: OCColors.cta,
    onCta: OCColors.onCta,
    ctaSoft: OCColors.ctaSoft,
    tertiary: OCColors.tertiary,
    onTertiary: OCColors.onTertiary,
    deep: OCColors.deep,
    lineStrong: OCColors.borderStrong,
    okInk: OCColors.successInk,
    errInk: OCColors.errorInk,
    warnInk: OCColors.warningInk,
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
    Color? cta,
    Color? onCta,
    Color? ctaSoft,
    Color? tertiary,
    Color? onTertiary,
    Color? deep,
    Color? lineStrong,
    Color? okInk,
    Color? errInk,
    Color? warnInk,
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
    cta: cta ?? this.cta,
    onCta: onCta ?? this.onCta,
    ctaSoft: ctaSoft ?? this.ctaSoft,
    tertiary: tertiary ?? this.tertiary,
    onTertiary: onTertiary ?? this.onTertiary,
    deep: deep ?? this.deep,
    lineStrong: lineStrong ?? this.lineStrong,
    okInk: okInk ?? this.okInk,
    errInk: errInk ?? this.errInk,
    warnInk: warnInk ?? this.warnInk,
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
      cta: c(cta, other.cta),
      onCta: c(onCta, other.onCta),
      ctaSoft: c(ctaSoft, other.ctaSoft),
      tertiary: c(tertiary, other.tertiary),
      onTertiary: c(onTertiary, other.onTertiary),
      deep: c(deep, other.deep),
      lineStrong: c(lineStrong, other.lineStrong),
      okInk: c(okInk, other.okInk),
      errInk: c(errInk, other.errInk),
      warnInk: c(warnInk, other.warnInk),
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

  // The design ships Tailwind's `shadow-sm/md/lg/xl`, which are all
  // `rgb(0 0 0 / 0.1)` - invisible on a #141312 canvas. The app is dark-locked,
  // so elevation is carried by the container ladder first and shadow second:
  // these are deeper than the HTML's, tuned to actually read on warm black.

  /// Cards. Lifts a `container-low` card off the canvas.
  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 3),
  ];

  static const cardHover = <BoxShadow>[
    BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 12),
  ];

  /// Raised chrome that is not a card: chips, segment rails, sticky headers.
  static const raised = <BoxShadow>[
    BoxShadow(color: Color(0x2E000000), offset: Offset(0, 2), blurRadius: 6),
  ];

  static const floatingCta = <BoxShadow>[
    BoxShadow(color: Color(0x59000000), offset: Offset(0, 6), blurRadius: 18),
  ];

  /// Bottom sheets and overlays: light comes from above.
  static const sheet = <BoxShadow>[
    BoxShadow(color: Color(0x66000000), offset: Offset(0, -4), blurRadius: 20),
  ];

  /// Terracotta glow for the primary send button.
  static const coloredCtaGlow = <BoxShadow>[
    BoxShadow(color: Color(0x3DFFB59E), offset: Offset(0, 2), blurRadius: 10),
  ];

  static const segmentedActive = <BoxShadow>[];
  static const toggleThumb = <BoxShadow>[
    BoxShadow(color: Color(0x40000000), offset: Offset(0, 1), blurRadius: 3),
  ];
}

class OCGradient {
  const OCGradient._();

  /// Accent fills only. The pastel ones are gone: a soft peach gradient is
  /// exactly what made the primary button read as a light-theme surface.
  static const ctaOrangeSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFE4E2DB)],
  );

  /// The terracotta ramp: `secondary` -> `secondary-fixed`.
  static const ctaSunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB59E), Color(0xFFFFA082)],
  );

  static const heroSky = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF201F1E), Color(0xFF1C1B1A)],
  );

  static const heroPastelBlend = heroSky;
  static const progressWarm = LinearGradient(
    colors: [Color(0xFFFFB59E), Color(0xFF7BB07A)],
  );
}

/// Shortcut: `context.oc.ink` instead of digging out the extension.
extension OCTokensX on BuildContext {
  OCTokens get oc => OCTokens.of(this);
}

/// 4/8/12/16/20/24/32. Nothing else.
class OCSpace {
  static const xs = 4.0;
  static const sm = 8.0;

  /// 14. The design's `gap-3.5` / `px-3.5` step, used for row padding and the
  /// gaps inside a card. Was 12 before the redesign.
  static const md = 14.0;

  /// 20. The design's `gap-5` / `p-5` step: composer padding, section gap.
  /// Was 16 before the redesign.
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// The scale, in order. For pickers and chips.
  static const scale = [xs, sm, md, lg, xl, xxl];

  /// The design's own Tailwind `gap-*` / `p-*` steps, 1 through 7, for the
  /// places that need 12 or 16 exactly instead of the shifted [md] / [lg].
  static const gap1 = 4.0;
  static const gap2 = 8.0;
  static const gap3 = 12.0;
  static const gap4 = 16.0;
  static const gap5 = 20.0;
  static const gap6 = 24.0;
  static const gap7 = 32.0;

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

  /// Legacy 6/40 steps. Kept so nothing has to be retuned in one pass.
  static const xxs = 6.0;
  static const xxxl = 40.0;
  static const ctaBottom = 24.0;

  /// Accessibility: every tappable element is at least 48x48. The design draws
  /// 44; 48 wins.
  static const tapTarget = 48.0;

  /// Minimum gap between two tappable elements.
  static const tapGap = 8.0;
}

/// Squircle-and-pills shape language. No sharp corners.
class OCRadius {
  /// 4 - the design's `rounded-sm`. 2dp status dots, tag chips.
  static const micro = 4.0;

  /// 8 - `rounded-lg`. Badges and small tiles.
  static const xs = 8.0;

  /// 12 - `rounded-xl`. Inner cells, small cards.
  static const sm = 12.0;

  /// 16 - `rounded-2xl`. Cards, the composer field.
  static const md = 16.0;

  /// 20 - the composer shell and bottom-sheet top.
  static const lg = 20.0;

  /// 24 - `rounded-3xl`. Modals, avatar blocks.
  static const xl = 24.0;

  /// 28 - large panels.
  static const xxl = 28.0;

  static const full = 9999.0;

  // --- named roles --------------------------------------------------------
  /// Cards and list rows. 16dp - `rounded-2xl`.
  static const card = 16.0;

  /// Compact rows: suggestion cards, file rows, session rows.
  static const row = 16.0;

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

/// Typography - Source Serif 4 / Inter / JetBrains Mono.
///
/// The design's own pairing: serif for titles and assistant prose, Inter for
/// UI and user text, JetBrains Mono for code. All three are variable fonts, so
/// every style sets `fontWeight` AND the `wght` axis - Flutter's font matcher
/// picks the closest named instance from the font manifest, while the variation
/// is what actually renders the right weight out of the single .ttf.
class OCTypography {
  // --- families -----------------------------------------------------------
  static const _serifFamily = 'SourceSerif4';
  static const _uiFamily = 'Inter';
  static const _monoFamily = 'JetBrainsMono';

  /// Generic-family fallbacks. These matter: if a variable .ttf is missing from
  /// `assets/fonts/`, Flutter logs "Unable to load font asset" and renders the
  /// next family in the list rather than nothing. `serif` / `sans-serif` /
  /// `monospace` are the platform generics, so the layout degrades gracefully
  /// instead of breaking.
  static const _serifFallback = [
    'serif',
    'NotoSerif',
    'Times New Roman',
  ];
  static const _fallback = ['sans-serif', 'Roboto', 'Poppins'];
  static const _monoFallback = [
    'monospace',
    'RobotoMono',
    'Menlo',
    'Consolas',
  ];

  static const fontFamily = _uiFamily;
  static const serifFamily = _serifFamily;
  static const monoFamily = _monoFamily;

  // --- builders -----------------------------------------------------------
  static List<FontVariation> _wght(FontWeight w) =>
      [FontVariation('wght', w.value.toDouble())];

  /// Inter. [opsz] is set to the rendered size so the optical size axis tracks
  /// the design's intent (crisper at small sizes, looser at display sizes).
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
    fontVariations: [
      ..._wght(weight),
      // double.clamp returns num, so it needs the explicit narrowing here.
      FontVariation('opsz', size.clamp(11.0, 32.0).toDouble()),
    ],
  );

  /// Source Serif 4 - screen headlines, section titles, assistant prose.
  static TextStyle _serif({
    required double size,
    required FontWeight weight,
    double height = 1.4,
    double spacing = 0,
    Color? color,
  }) => TextStyle(
    fontFamily: _serifFamily,
    fontFamilyFallback: _serifFallback,
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: spacing,
    color: color,
    fontVariations: _wght(weight),
  );

  /// JetBrains Mono.
  static TextStyle _mono({
    required double size,
    required FontWeight weight,
    required double height,
    double spacing = 0,
    Color? color,
  }) => TextStyle(
    fontFamily: _monoFamily,
    fontFamilyFallback: _monoFallback,
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: spacing,
    color: color,
    fontVariations: _wght(weight),
  );

  // --- serif roles --------------------------------------------------------

  /// 32 / 38 / 600 - screen headline. One per screen, at most.
  static final headline = _serif(
    size: 32,
    weight: FontWeight.w600,
    height: 38 / 32,
    spacing: -0.4,
  );

  /// 20 / 26 / 600 - card titles and section titles.
  static final titleLarge = _serif(
    size: 20,
    weight: FontWeight.w600,
    height: 26 / 20,
    spacing: -0.2,
  );

  /// 16.5 / 26 / 400 - ASSISTANT message prose. The design sets assistant text
  /// in serif and user text in Inter; [body] is Inter, so chat must ask for
  /// this one explicitly on the assistant side.
  static final assistantBody = _serif(
    size: 16.5,
    weight: FontWeight.w400,
    height: 26 / 16.5,
  );

  // --- Inter roles --------------------------------------------------------

  /// 13 / 18 / 600 / +0.6 - the design's uppercase tracked section label
  /// ("OVERVIEW", "Recents").
  static final section = _sans(
    size: 13,
    weight: FontWeight.w600,
    height: 18 / 13,
    spacing: 0.6,
  );

  /// 15 / 22 / 500 - row titles.
  static final title = _sans(
    size: 15,
    weight: FontWeight.w500,
    height: 22 / 15,
    spacing: -0.1,
  );

  /// 15 / 22 / 400 - body copy, USER message text.
  static final body = _sans(size: 15, weight: FontWeight.w400, height: 22 / 15);

  /// 13 / 18 - captions: timestamps, meta, hints.
  static final caption = _sans(
    size: 13,
    weight: FontWeight.w400,
    height: 18 / 13,
    spacing: 0.1,
  );

  // --- weights the screens need on top of the four steps -----------------

  /// 14 / 20 / 600 - button labels.
  static final button = _sans(size: 14, weight: FontWeight.w600, height: 20 / 14);

  /// 13 / 18 / 500 - chip and pill labels.
  static final meta = _sans(size: 13, weight: FontWeight.w500, height: 18 / 13);

  /// 13 / 18 / 600 - selected chip labels.
  static final metaStrong = _sans(
    size: 13,
    weight: FontWeight.w600,
    height: 18 / 13,
  );

  /// 11 / 14 / 500 / +0.3 - badges, status dots, the smallest step in the app.
  static final micro = _sans(
    size: 11,
    weight: FontWeight.w500,
    height: 14 / 11,
    spacing: 0.3,
  );

  /// 13 / 18 / 600 - message sender label.
  static final label = _sans(size: 13, weight: FontWeight.w600, height: 18 / 13);

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
    double height = 1.5,
    FontWeight weight = FontWeight.w400,
  }) => _mono(
    size: size,
    weight: weight,
    height: height,
    color: color,
  );

  static TextStyle monoSmall({Color? color}) =>
      mono(color: color, size: 11.5, height: 16 / 11.5);

  static TextStyle monoLarge({Color? color}) =>
      mono(color: color, size: 16, height: 24 / 16);

  /// Inline `code` spans inside prose.
  static TextStyle code({Color? color, double size = 13}) =>
      mono(color: color, size: size, height: 1.4);

  /// Fenced code blocks.
  static TextStyle codeBlock({Color? color, double size = 12.5}) =>
      mono(color: color, size: size, height: 18 / 12.5);

  // --- legacy aliases, so existing call sites keep compiling --------------
  //
  // h2/h3 stay on the Inter `title` role, not on the serif `titleLarge`: every
  // current call site uses them for a row title, an empty-state title or a
  // dialog title, not a screen section. Serif at those sizes reads as a
  // mistake; batches 3-7 opt into `titleLarge` where the design actually asks
  // for a serif section heading.
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
  static TextStyle get heroTitle => headline;
  static TextStyle get subtitle => caption;
  static TextStyle get overline => section;
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
