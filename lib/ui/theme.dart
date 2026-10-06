// Design tokens — "Playful Soft-UI" (design-system.json v1.0.0).
// Single source of truth for colour, type, spacing, shape, elevation and motion.
// Nothing in the app should hard-code a colour, radius, shadow or text size.

import 'dart:ui' show FontFeature, FontVariation;

import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

// Split out of the original 1253-line theme.dart. Every part below holds whole
// top-level declarations moved verbatim: a pure move, no logic touched.
part 'theme/theme_colors.dart';
part 'theme/theme_tokens.dart';
part 'theme/theme_radius_typography.dart';
part 'theme/theme_build_theme.dart';
