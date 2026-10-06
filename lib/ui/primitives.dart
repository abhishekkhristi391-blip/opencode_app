// Design-system primitives: Button, Card, InnerCell, IconTile, Avatar(+Stack),
// Toggle, SegmentedControl, Progress, Chip, ListRow, Breadcrumbs, Skeleton.
//
// Rules baked in here:
//  * min 48x48 tap target (the design draws 44; 48 wins)
//  * press = scale(0.97), disabled = 40% opacity
//  * two action colours only: white `cta` for the primary action, terracotta
//    `accent` for secondary/selected. No third hue is a button.
//  * surfaces come from the container ladder in theme.dart, never from a border
//  * status is never colour-only (dots ship with a label or icon)
//  * no hard-coded colours/sizes: everything comes from theme.dart tokens

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

// Split out of the original 1556-line primitives.dart. Every part below holds whole
// top-level declarations moved verbatim: a pure move, no logic touched.
part 'primitives/primitives_buttons_cards.dart';
part 'primitives/primitives_cells_controls.dart';
part 'primitives/primitives_progress_chip.dart';
part 'primitives/primitives_rows_skeleton.dart';
