// Hand-rolled line icons.
//
// The designs use Material Symbols *outlined* glyphs at a 1.5px stroke with
// round caps. Flutter has no font of its own that matches, so the glyphs the
// screens actually use are drawn here on a 24x24 grid.
//
// Scope rule: only glyphs a screen in `design/` uses are drawn. Fabricated
// glyphs are not added speculatively, because an unused enum value is dead code
// that still has to be switched over.
//
// Add a glyph by extending [LI] and adding one `case` to [LLinePainter].
// Prefer keeping the shape to straight lines, quadratics and `addArc` on a
// circle whose start point matches the current point.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

// Split out of the original 1209-line line_icons.dart. Every part below holds whole
// top-level declarations moved verbatim: a pure move, no logic touched.
part 'line_icons/line_icons_widgets.dart';
part 'line_icons/line_icons_painter.dart';
