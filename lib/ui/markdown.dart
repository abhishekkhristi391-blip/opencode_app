// Compact markdown renderer tuned for agent output: inline styles, fenced
// code blocks, headings, lists, blockquotes and tables.
//
// Perf fixes vs. the old version:
//  * inline parser was O(n * tokens * 8): every token re-ran all 8 regexes
//    over the whole rest of the string and built a span for EVERY match.
//    Now each rule is searched lazily and only the winning match builds a span.
//  * block regexes are hoisted to static finals (they were re-created per line)
//  * ONE SelectionArea per Markdown instead of one per paragraph / list row
//  * small LRU cache of parsed blocks (scrolling tiles back in = no re-parse)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/strings.dart';
import 'theme.dart';
import 'line_icons.dart';

// Split out of the original 599-line markdown.dart. Every part below holds whole
// top-level declarations moved verbatim: a pure move, no logic touched.
part 'markdown/markdown_renderer.dart';
part 'markdown/markdown_code_block.dart';
