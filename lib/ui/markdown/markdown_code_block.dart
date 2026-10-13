part of '../markdown.dart';

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
    final fence = _fenceRe.firstMatch(line);
    if (fence != null) {
      flushPara();
      final marker = fence.group(1)![0];
      final len = fence.group(1)!.length;
      final closeRe = RegExp('^\\s*${RegExp.escape(marker)}{$len,}\\s*\$');
      final body = <String>[];
      i++;
      while (i < lines.length) {
        final c = lines[i];
        if (closeRe.hasMatch(c)) {
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
    final h = _headingRe.firstMatch(line);
    if (h != null) {
      flushPara();
      out.add(_Block(_Kind.heading, [h.group(2)!], level: h.group(1)!.length));
      i++;
      continue;
    }

    // horizontal rule
    if (_hrRe.hasMatch(line)) {
      flushPara();
      out.add(_Block(_Kind.hr, const []));
      i++;
      continue;
    }

    // blockquote
    if (_quoteRe.hasMatch(line)) {
      flushPara();
      final body = <String>[];
      while (i < lines.length && _quoteRe.hasMatch(lines[i])) {
        body.add(lines[i].replaceFirst(_quoteStripRe, ''));
        i++;
      }
      out.add(_Block(_Kind.quote, body));
      continue;
    }

    // table
    if (line.contains('|') &&
        i + 1 < lines.length &&
        _tableSepRe.hasMatch(lines[i + 1])) {
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
    if (_listItemRe.hasMatch(line)) {
      flushPara();
      final body = <String>[];
      final ordered = _orderedItemRe.hasMatch(line);
      while (i < lines.length) {
        final l = lines[i];
        if (_listItemRe.hasMatch(l)) {
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
    final t = OCTokens.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Reference `--code`: dark in both themes.
        color: t.code,
        // `rounded-2xl`, not 12.
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59000000),
            offset: Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      // The header strip is a filled band, so it has to be clipped by the
      // block's radius instead of painting square corners over it.
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
              OCSpace.md,
              8,
              OCSpace.xs,
              8,
            ),
            decoration: const BoxDecoration(color: OCColors.surfaceHigh),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lang.isEmpty ? 'code' : lang,
                    style: OCTypography.mono(size: 11, color: t.codeInk),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 16,
                  tooltip: S.copy,
                  icon: LIcon(LI.copy, size: 16, color: t.codeInk),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(S.codeCopied),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              OCSpace.md,
              OCSpace.sm,
              OCSpace.md,
              OCSpace.md,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                code,
                style: OCTypography.mono(
                  size: 12.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
