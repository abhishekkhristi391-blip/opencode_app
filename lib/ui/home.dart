import 'dart:async';

import 'package:flutter/material.dart';

import '../api/client.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/store.dart';
import 'app_scope.dart';
import 'about_page.dart';
import 'buddy_avatar.dart';
import 'chat.dart';
import 'commands_page.dart';
import 'diff_page.dart';
import 'files_page.dart';
import 'line_icons.dart';
import 'models_page.dart';
import 'primitives.dart';
import 'prompts.dart';
import 'sessions_page.dart';
import 'settings_page.dart';
import 'terminal_page.dart';
import 'theme.dart';
import 'todos_page.dart';
import 'widgets.dart';

// Split out of the original 1858-line home.dart. Every part below holds whole
// top-level declarations moved verbatim: a pure move, no logic touched.
part 'home/home_shell.dart';
part 'home/home_avatar_drawer.dart';
part 'home/home_drawer_rows.dart';
part 'home/home_server_menu.dart';
