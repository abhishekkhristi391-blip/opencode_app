import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute, debugPrint, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../models/models.dart';
import '../l10n/strings.dart';

// Split out of the original 847-line client.dart. Every part below holds whole
// top-level declarations moved verbatim: a pure move, no logic touched.
part 'client/client_oc_client.dart';
part 'client/client_provider_types.dart';

// OcClient's endpoint methods, split by topic into extensions (see client_oc_client.dart).
part 'client/client_oc_client_http.dart';
part 'client/client_oc_client_server.dart';
part 'client/client_oc_client_sessions.dart';
part 'client/client_oc_client_messages.dart';
part 'client/client_oc_client_workspace.dart';
