import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/store.dart';
import 'app_scope.dart';
import 'chat.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';
import '../api/client.dart';

// Split out of the original 772-line sessions_page.dart. Every part below holds whole
// top-level declarations moved verbatim: a pure move, no logic touched.
part 'sessions_page/sessions_page_main.dart';
part 'sessions_page/sessions_page_tiles.dart';
