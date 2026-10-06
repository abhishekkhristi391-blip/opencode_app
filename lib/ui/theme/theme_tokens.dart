part of '../theme.dart';

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
