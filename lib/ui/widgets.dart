import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/store.dart';
import 'line_icons.dart';
import 'primitives.dart';
import 'theme.dart';

// Split out of the original 987-line widgets.dart. Every part below holds whole
// top-level declarations moved verbatim: a pure move, no logic touched.
part 'widgets/widgets_navigation_feedback.dart';
part 'widgets/widgets_headers_pills.dart';
part 'widgets/widgets_header_button.dart';
