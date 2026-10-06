part of '../markdown.dart';

class Markdown extends StatelessWidget {
  final String text;
  final TextStyle? base;
  final bool selectable;
  final void Function(String url)? onLink;
  const Markdown(
    this.text, {
    super.key,
    this.base,
    this.selectable = true,
    this.onLink,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = base ?? theme.textTheme.bodyMedium!;
    final blocks = _parseCached(text);
    if (blocks.isEmpty) return const SizedBox.shrink();
    final col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < blocks.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == blocks.length - 1 ? 0 : 8),
            child: _buildBlock(context, blocks[i], style),
          ),
      ],
    );
    return selectable ? SelectionArea(child: col) : col;
  }

  Widget _buildBlock(BuildContext context, _Block b, TextStyle style) {
    switch (b.kind) {
      case _Kind.code:
        return _CodeBlock(code: b.lines.join('\n'), lang: b.lang);
      case _Kind.heading:
        final sizes = [20.0, 18.0, 16.5, 15.0, 14.5, 14.0];
        final s = sizes[(b.level - 1).clamp(0, 5)];
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 2),
          child: _rich(
            context,
            b.lines.join(' '),
            style.copyWith(
              fontSize: s,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        );
      case _Kind.quote:
        return Container(
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 3,
              ),
            ),
          ),
          child: _rich(
            context,
            b.lines.join('\n'),
            style.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      case _Kind.bullet:
      case _Kind.number:
        return _listBlock(context, b, style);
      case _Kind.table:
        return _table(context, b, style);
      case _Kind.hr:
        return Divider(
          color: Theme.of(context).colorScheme.outlineVariant,
          height: 12,
        );
      default:
        return _paragraph(context, b, style);
    }
  }

  Widget _paragraph(BuildContext context, _Block b, TextStyle style) {
    // Preserve hard line breaks inside a paragraph the way terminals do.
    final spans = <InlineSpan>[];
    for (var i = 0; i < b.lines.length; i++) {
      spans.addAll(_inlineSpans(context, b.lines[i], style));
      if (i != b.lines.length - 1) spans.add(const TextSpan(text: '\n'));
    }
    return Text.rich(TextSpan(children: spans, style: style));
  }

  Widget _listBlock(BuildContext context, _Block b, TextStyle style) {
    final ordered = b.kind == _Kind.number;
    final markerColor = Theme.of(context).colorScheme.outline;
    Widget row(int i) {
      final line = b.lines[i];
      final isItem = ordered || _listItemRe.hasMatch(line);
      final marker = isItem
          ? (ordered ? '${i + 1}.' : _bulletMarker(line))
          : '';
      final text = isItem
          ? line.replaceFirst(_listItemRe, '')
          : line.trimLeft();
      return Padding(
        padding: const EdgeInsets.only(left: 4, top: 1, bottom: 1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: ordered ? 22 : 14,
              child: Text(marker, style: style.copyWith(color: markerColor)),
            ),
            Expanded(child: _rich(context, text, style)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (var i = 0; i < b.lines.length; i++) row(i)],
    );
  }

  static final _bulletRe = RegExp(r'^\s*([-*+])');
  static String _bulletMarker(String line) =>
      _bulletRe.firstMatch(line)?.group(1) ?? '•';

  static final _tableEdgeRe = RegExp(r'^\s*\||\|\s*$');

  Widget _table(BuildContext context, _Block b, TextStyle style) {
    final rows = <List<String>>[];
    for (final l in b.lines) {
      if (_tableSepRe.hasMatch(l)) continue;
      rows.add(
        l.replaceAll(_tableEdgeRe, '').split('|').map((e) => e.trim()).toList(),
      );
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    final header = rows.first;
    final body = rows.skip(1).toList();
    final borderColor = Theme.of(context).colorScheme.outlineVariant;
    final border = BorderSide(color: borderColor);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                for (final c in header)
                  Expanded(
                    child: _rich(
                      context,
                      c,
                      style.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          for (var r = 0; r < body.length; r++)
            Container(
              decoration: BoxDecoration(
                border: r == body.length - 1 ? null : Border(bottom: border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var c = 0; c < header.length; c++)
                    Expanded(
                      child: c < body[r].length
                          ? _rich(context, body[r][c], style)
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _rich(BuildContext context, String text, TextStyle style) => Text.rich(
    TextSpan(children: _inlineSpans(context, text, style), style: style),
  );

  // ---------------------------------------------------------------------
  // inline parsing
  // ---------------------------------------------------------------------

  // Order matters for ties (earlier rule wins): code, link, autolink, bold,
  // bold2, strike, italic, italic2.
  static final _rules = <RegExp>[
    RegExp(r'`([^`\n]+)`'),
    RegExp(r'\[([^\]\n]*)\]\(([^)\s]+)(?:\s+"[^"]*")?\)'),
    RegExp(r'(?<![(\w])(https?://[^\s<>()\[\]]+)'),
    RegExp(r'\*\*([^*\n]+)\*\*'),
    RegExp(r'(?<![_\w])__([^_\n]+)__(?!_)'),
    RegExp(r'~~([^~\n]+)~~'),
    RegExp(r'(?<![*\w])\*([^*\n]+)\*(?!\*)'),
    RegExp(r'(?<![_\w])_([^_\n]+)_(?!_)'),
  ];

  static final _maybeInlineRe = RegExp(r'[`*_~\[]|https?://');

  static RegExpMatch? _firstFrom(RegExp re, String s, int from) {
    final it = re.allMatches(s, from).iterator;
    return it.moveNext() ? it.current : null;
  }

  List<InlineSpan> _inlineSpans(
    BuildContext context,
    String src,
    TextStyle style,
  ) {
    final spans = <InlineSpan>[];
    final n = src.length;
    if (n == 0) return spans;

    // Fast path: nothing that could start inline markup.
    if (!_maybeInlineRe.hasMatch(src)) {
      spans.add(TextSpan(text: src));
      return spans;
    }

    final cache = List<RegExpMatch?>.filled(_rules.length, null);
    final searched = List<bool>.filled(_rules.length, false);
    var pos = 0;

    while (pos < n) {
      var bestRule = -1;
      RegExpMatch? best;
      for (var r = 0; r < _rules.length; r++) {
        var m = cache[r];
        if (!searched[r] || (m != null && m.start < pos)) {
          m = _firstFrom(_rules[r], src, pos);
          cache[r] = m;
          searched[r] = true;
        }
        if (m != null && (best == null || m.start < best.start)) {
          best = m;
          bestRule = r;
        }
      }
      if (best == null) break;
      if (best.start > pos)
        spans.add(TextSpan(text: src.substring(pos, best.start)));
      spans.add(_makeSpan(context, bestRule, best, style));
      pos = best.end;
    }
    if (pos < n) spans.add(TextSpan(text: src.substring(pos)));
    return spans;
  }

  InlineSpan _makeSpan(
    BuildContext context,
    int rule,
    RegExpMatch m,
    TextStyle style,
  ) {
    switch (rule) {
      case 0:
        return TextSpan(text: m.group(1), style: _codeStyle(context, style));
      case 1:
        final label = m.group(1)!.isEmpty ? m.group(2)! : m.group(1)!;
        return _linkSpan(context, label, m.group(2)!, style);
      case 2:
        return _linkSpan(context, m.group(1)!, m.group(1)!, style);
      case 3:
      case 4:
        return TextSpan(
          text: m.group(1),
          style: style.copyWith(fontWeight: FontWeight.w700),
        );
      case 5:
        return TextSpan(
          text: m.group(1),
          style: style.copyWith(decoration: TextDecoration.lineThrough),
        );
      default:
        return TextSpan(
          text: m.group(1),
          style: style.copyWith(fontStyle: FontStyle.italic),
        );
    }
  }

  InlineSpan _linkSpan(
    BuildContext context,
    String label,
    String url,
    TextStyle style,
  ) {
    final color = Theme.of(context).colorScheme.primary;
    final recognizer = TapGestureRecognizer()
      ..onTap = () {
        if (onLink != null) {
          onLink!(url);
        } else {
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      };
    return TextSpan(
      text: label,
      style: style.copyWith(color: color, decoration: TextDecoration.underline),
      recognizer: recognizer,
      mouseCursor: SystemMouseCursors.click,
    );
  }

  static TextStyle _codeStyle(BuildContext context, TextStyle base) {
    // Inline code takes fixed palette steps rather than token reads: the tint
    // pairs with the assistant prose it always appears inside, and the dark
    // code *blocks* use OCTokens.code instead.
    return base.copyWith(
      fontFamily: OCTypography.mono(color: null).fontFamily,
      fontSize: (base.fontSize ?? 14) - 0.5,
      // The reference's `bg-surface-container-high text-tertiary-fixed-dim`:
      // a blue-tinted token so a symbol inside prose never reads as body text.
      backgroundColor: OCColors.surfaceHigh,
      color: OCColors.codeAccent,
      fontWeight: FontWeight.w500,
    );
  }
}

// ---------------------------------------------------------------------
// block parsing
// ---------------------------------------------------------------------

enum _Kind { para, code, heading, bullet, number, quote, table, hr }

class _Block {
  final _Kind kind;
  final List<String> lines;
  final int level;
  final String lang;
  _Block(this.kind, this.lines, {this.level = 1, this.lang = ''});
}

// Hoisted: these used to be constructed again for every single line.
final _fenceRe = RegExp(r'^\s*(`{3,}|~{3,})\s*([\w+-]*)\s*$');

final _headingRe = RegExp(r'^\s{0,3}(#{1,6})\s+(.*)$');

final _hrRe = RegExp(r'^\s{0,3}([-*_])\s*(\1\s*){2,}$');

final _quoteRe = RegExp(r'^\s{0,3}>');

final _quoteStripRe = RegExp(r'^\s{0,3}>\s?');

final _tableSepRe = RegExp(r'^\s*\|?[\s:|-]+\|[\s:|-]*$');

final _listItemRe = RegExp(r'^\s*([-*+]|\d+[.)])\s+');

final _orderedItemRe = RegExp(r'^\s*\d+[.)]\s');

// Small LRU cache: re-building a tile (scroll back, theme change) is free.
final _parseCache = <String, List<_Block>>{};

List<_Block> _parseCached(String src) {
  final hit = _parseCache.remove(src);
  if (hit != null) {
    _parseCache[src] = hit;
    return hit;
  }
  final r = _parse(src);
  _parseCache[src] = r;
  if (_parseCache.length > 40) _parseCache.remove(_parseCache.keys.first);
  return r;
}
