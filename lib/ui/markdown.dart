// Compact markdown renderer tuned for agent output: inline styles, fenced
// code blocks, headings, lists, blockquotes and tables.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Markdown extends StatelessWidget {
  final String text;
  final TextStyle? base;
  final bool selectable;
  const Markdown(this.text, {super.key, this.base, this.selectable = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = base ?? theme.textTheme.bodyMedium!;
    final blocks = _parse(text);
    if (blocks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < blocks.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == blocks.length - 1 ? 0 : 8),
            child: _buildBlock(context, blocks[i], style),
          ),
      ],
    );
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
          child: _inline(context, b.lines.join(' '),
              style.copyWith(fontSize: s, fontWeight: FontWeight.w700, height: 1.3)),
        );
      case _Kind.quote:
        return Container(
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 3)),
          ),
          child: _inline(context, b.lines.join('\n'), style.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        );
      case _Kind.bullet:
      case _Kind.number:
        return _listBlock(context, b, style);
      case _Kind.table:
        return _table(context, b, style);
      case _Kind.hr:
        return Divider(color: Theme.of(context).colorScheme.outlineVariant, height: 12);
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
    return _wrap(context, Text.rich(TextSpan(children: spans, style: style)));
  }

  Widget _listBlock(BuildContext context, _Block b, TextStyle style) {
    final ordered = b.kind == _Kind.number;
    Widget row(int i) {
      final line = b.lines[i];
      final isItem = ordered || RegExp(r'^\s*([-*+]|\d+[.)])\s+').hasMatch(line);
      final marker = isItem
          ? (ordered ? '${i + 1}.' : _bulletMarker(line))
          : '';
      final text = isItem ? line.replaceFirst(RegExp(r'^\s*([-*+]|\d+[.)])\s+'), '') : line.trimLeft();
      return Padding(
        padding: const EdgeInsets.only(left: 4, top: 1, bottom: 1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: ordered ? 22 : 14,
              child: Text(
                marker,
                style: style.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            Expanded(child: _wrap(context, _rich(context, text, style))),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (var i = 0; i < b.lines.length; i++) row(i)],
    );
  }

  static String _bulletMarker(String line) {
    final m = RegExp(r'^\s*([-*+])').firstMatch(line);
    return m?.group(1) ?? '•';
  }

  Widget _table(BuildContext context, _Block b, TextStyle style) {
    final rows = <List<String>>[];
    for (final l in b.lines) {
      if (RegExp(r'^\s*\|?[\s:|-]+\|[\s:|-]*$').hasMatch(l)) continue;
      rows.add(l.replaceAll(RegExp(r'^\s*\||\|\s*$'), '').split('|').map((e) => e.trim()).toList());
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
                for (final c in header) Expanded(child: _inline(context, c, style.copyWith(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          for (var r = 0; r < body.length; r++)
            Container(
              decoration: BoxDecoration(border: r == body.length - 1 ? null : Border(bottom: border)),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var c = 0; c < header.length; c++)
                    Expanded(
                      child: c < body[r].length
                          ? _inline(context, body[r][c], style)
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _wrap(BuildContext context, Widget child) =>
      selectable ? SelectionArea(child: child) : child;

  Widget _rich(BuildContext context, String text, TextStyle style) =>
      Text.rich(TextSpan(children: _inlineSpans(context, text, style), style: style));

  Widget _inline(BuildContext context, String text, TextStyle style) => _rich(context, text, style);

  // ---------------------------------------------------------------------
  // inline parsing
  // ---------------------------------------------------------------------

  static final _code = RegExp(r'`([^`\n]+)`');
  static final _bold = RegExp(r'\*\*([^*\n]+)\*\*');
  static final _bold2 = RegExp(r'(?<![_\w])__([^_\n]+)__(?!_)');
  static final _italic = RegExp(r'(?<![*\w])\*([^*\n]+)\*(?!\*)');
  static final _italic2 = RegExp(r'(?<![_\w])_([^_\n]+)_(?!_)');
  static final _strike = RegExp(r'~~([^~\n]+)~~');
  static final _link = RegExp(r'\[([^\]\n]*)\]\(([^)\s]+)(?:\s+"[^"]*")?\)');
  static final _autoLink = RegExp(r'(?<![(\w])(https?://[^\s<>()\[\]]+)');

  List<InlineSpan> _inlineSpans(BuildContext context, String src, TextStyle style) {
    final spans = <InlineSpan>[];
    var rest = src;

    void addPlain(String t) {
      if (t.isEmpty) return;
      spans.add(_auto(context, t, style));
    }

    while (true) {
      final candidates = <({int start, int end, InlineSpan? span})>[];

      void consider(RegExp re, InlineSpan? Function(RegExpMatch) make) {
        for (final m in re.allMatches(rest)) {
          candidates.add((start: m.start, end: m.end, span: make(m)));
        }
      }

      consider(_code, (m) => TextSpan(
            text: m.group(1),
            style: _codeStyle(context, style),
          ));
      consider(_link, (m) => _linkSpan(context, m.group(1)!.isEmpty ? m.group(2)! : m.group(1)!, m.group(2)!, style));
      consider(_autoLink, (m) => _linkSpan(context, m.group(1)!, m.group(1)!, style));
      consider(_bold, (m) => TextSpan(text: m.group(1), style: style.copyWith(fontWeight: FontWeight.w700)));
      consider(_bold2, (m) => TextSpan(text: m.group(1), style: style.copyWith(fontWeight: FontWeight.w700)));
      consider(_strike, (m) => TextSpan(text: m.group(1), style: style.copyWith(decoration: TextDecoration.lineThrough)));
      consider(_italic, (m) => TextSpan(text: m.group(1), style: style.copyWith(fontStyle: FontStyle.italic)));
      consider(_italic2, (m) => TextSpan(text: m.group(1), style: style.copyWith(fontStyle: FontStyle.italic)));

      if (candidates.isEmpty) {
        addPlain(rest);
        break;
      }
      candidates.sort((a, b) => a.start.compareTo(b.start));
      final best = candidates.first;
      addPlain(rest.substring(0, best.start));
      if (best.span != null) spans.add(best.span!);
      rest = rest.substring(best.end);
    }
    return spans;
  }

  InlineSpan _auto(BuildContext context, String t, TextStyle style) => TextSpan(text: t);

  InlineSpan _linkSpan(BuildContext context, String label, String url, TextStyle style) {
    final color = Theme.of(context).colorScheme.primary;
    return TextSpan(
      text: label,
      style: style.copyWith(color: color, decoration: TextDecoration.underline),
      recognizer: null,
      mouseCursor: SystemMouseCursors.click,
      // Tap handling is wired by the caller through [onLink] if needed.
    );
  }

  static TextStyle _codeStyle(BuildContext context, TextStyle base) => base.copyWith(
        fontFamily: 'monospace',
        fontFamilyFallback: const ['monospace'],
        fontSize: (base.fontSize ?? 14) - 0.5,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        color: Theme.of(context).colorScheme.onSurface,
      );
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

List<_Block> _parse(String src) {
  final lines = src.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
  final out = <_Block>[];
  final para = <String>[];
  var i = 0;

  void flushPara() {
    if (para.isNotEmpty) {
      out.add(_Block(_Kind.para, [...para]));
      para.clear();
    }
  }

  while (i < lines.length) {
    final line = lines[i];

    // fenced code
    final fence = RegExp(r'^\s*(`{3,}|~{3,})\s*([\w+-]*)\s*$').firstMatch(line);
    if (fence != null) {
      flushPara();
      final marker = fence.group(1)![0];
      final len = fence.group(1)!.length;
      final body = <String>[];
      i++;
      while (i < lines.length) {
        final c = lines[i];
        if (RegExp('^\\s*${RegExp.escape(marker)}{$len,}\\s*\$').hasMatch(c)) {
          i++;
          break;
        }
        body.add(c);
        i++;
      }
      out.add(_Block(_Kind.code, body, lang: fence.group(2) ?? ''));
      continue;
    }

    // heading
    final h = RegExp(r'^\s{0,3}(#{1,6})\s+(.*)$').firstMatch(line);
    if (h != null) {
      flushPara();
      out.add(_Block(_Kind.heading, [h.group(2)!], level: h.group(1)!.length));
      i++;
      continue;
    }

    // horizontal rule
    if (RegExp(r'^\s{0,3}([-*_])\s*(\1\s*){2,}$').hasMatch(line)) {
      flushPara();
      out.add(_Block(_Kind.hr, const []));
      i++;
      continue;
    }

    // blockquote
    if (RegExp(r'^\s{0,3}>').hasMatch(line)) {
      flushPara();
      final body = <String>[];
      while (i < lines.length && RegExp(r'^\s{0,3}>').hasMatch(lines[i])) {
        body.add(lines[i].replaceFirst(RegExp(r'^\s{0,3}>\s?'), ''));
        i++;
      }
      out.add(_Block(_Kind.quote, body));
      continue;
    }

    // table
    if (line.contains('|') && i + 1 < lines.length && RegExp(r'^\s*\|?[\s:|-]+\|[\s:|-]*$').hasMatch(lines[i + 1])) {
      flushPara();
      final body = <String>[];
      while (i < lines.length && lines[i].contains('|')) {
        body.add(lines[i]);
        i++;
      }
      out.add(_Block(_Kind.table, body));
      continue;
    }

    // lists (a blank line does not break a list)
    if (RegExp(r'^\s*([-*+]|\d+[.)])\s+').hasMatch(line)) {
      flushPara();
      final body = <String>[];
      final ordered = RegExp(r'^\s*\d+[.)]\s').hasMatch(line);
      while (i < lines.length) {
        final l = lines[i];
        if (RegExp(r'^\s*([-*+]|\d+[.)])\s+').hasMatch(l)) {
          body.add(l);
        } else if (l.trim().isEmpty) {
          break;
        } else {
          // continuation line of the previous item
          body.add(l);
        }
        i++;
      }
      out.add(_Block(ordered ? _Kind.number : _Kind.bullet, body));
      continue;
    }

    if (line.trim().isEmpty) {
      flushPara();
      i++;
      continue;
    }

    para.add(line);
    i++;
  }
  flushPara();
  return out;
}

// ---------------------------------------------------------------------
// code block widget
// ---------------------------------------------------------------------

class _CodeBlock extends StatelessWidget {
  final String code, lang;
  const _CodeBlock({required this.code, required this.lang});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lang.isEmpty ? 'code' : lang,
                    style: TextStyle(fontSize: 11, color: cs.outline, fontFamily: 'monospace'),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 16,
                  tooltip: 'Copy',
                  icon: const Icon(Icons.copy_all_outlined),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copy ho gaya'), duration: Duration(seconds: 1)));
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontFamilyFallback: ['monospace'],
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
