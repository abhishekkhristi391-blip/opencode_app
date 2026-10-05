import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/client.dart';
import '../api/events.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../db/chat_db.dart';

// Split out of the original 2579-line store.dart. Every part below is a verbatim
// line range of that file: a pure move, no logic touched.
part 'store/store_types.dart';
part 'store/store_ocstore.dart';
