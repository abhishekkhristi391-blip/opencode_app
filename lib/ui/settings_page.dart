import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';

import '../api/client.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/store.dart';
import '../voice/voice_scope.dart';
import '../voice/voice_service.dart';
import '../widgets/buddy.dart';
import 'app_scope.dart';
import 'chat.dart' show voiceFailureText;
import 'commands_page.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';

// Split out of the original 1213-line settings_page.dart. Every part below holds whole
// top-level declarations moved verbatim: a pure move, no logic touched.
part 'settings_page/settings_page_body.dart';
part 'settings_page/settings_page_sections.dart';
part 'settings_page/settings_page_voice_tiles.dart';
