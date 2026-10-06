import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/store.dart';
import 'app_scope.dart';
import 'line_icons.dart';
import 'primitives.dart';
import 'theme.dart';
import 'widgets.dart';

// Split out of the original 673-line prompts.dart. Every part below holds whole
// top-level declarations moved verbatim: a pure move, no logic touched.
part 'prompts/prompts_permission.dart';
part 'prompts/prompts_question.dart';
