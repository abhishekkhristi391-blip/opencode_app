part of '../theme.dart';

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

  /// The composer card. The reference draws `rounded-[26px]`.
  static const composer = 26.0;

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
