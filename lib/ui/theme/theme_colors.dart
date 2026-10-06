part of '../theme.dart';

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

  /// Terminal viewport. The reference draws the terminal window as
  /// `container-lowest`, one step below the canvas, so the output well is
  /// deeper than the `container-low` card its header sits on.
  static const terminalBg = _lowest;

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
  /// `surface-container-highest` - the reference draws code blocks as the
  /// highest step of the container ladder, not a well below the canvas, so the
  /// header strip one step down (`surfaceHigh`) reads as a lighter band.
  static const codeBg = _highest;
  static const codeInk = Color(0xFFC8C7BE);

  /// `tertiary-fixed-dim` - inline code tint inside assistant prose.
  static const codeAccent = Color(0xFFA0C9FF);

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
