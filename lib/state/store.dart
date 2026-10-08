import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/client.dart';
import '../api/events.dart';
import '../widgets/buddy.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../db/chat_db.dart';

// Split out of the original 2579-line store.dart. Every part below is a verbatim
// line range of that file: a pure move, no logic touched.
part 'store/store_types.dart';
part 'store/store_ocstore.dart';

// OcStore's behaviour, split by topic into extensions (see store_ocstore.dart). Moved
// verbatim, except references to OcStore's statics are written OcStore.name.
part 'store/store_ocstore_view_state.dart';
part 'store/store_ocstore_cache.dart';
part 'store/store_ocstore_connection.dart';
part 'store/store_ocstore_sessions.dart';
part 'store/store_ocstore_history.dart';
part 'store/store_ocstore_run.dart';
part 'store/store_ocstore_workspace.dart';
part 'store/store_ocstore_prompts.dart';
part 'store/store_ocstore_events.dart';
part 'store/store_ocstore_messages.dart';
