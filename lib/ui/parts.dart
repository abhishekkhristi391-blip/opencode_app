import '../l10n/strings.dart';

import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../state/store.dart';
import 'app_scope.dart';
import 'line_icons.dart';
import 'markdown.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';

// Split out of the original 989-line parts.dart. Every part below holds whole
// top-level declarations moved verbatim: a pure move, no logic touched.
part 'parts/parts_tool_timeline.dart';
part 'parts/parts_tool_tile.dart';
part 'parts/parts_file_agent_diff.dart';
