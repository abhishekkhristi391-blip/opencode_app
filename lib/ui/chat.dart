import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/store.dart';
import 'app_scope.dart';
import 'line_icons.dart';
import 'markdown.dart';
import 'models_page.dart';
import 'parts.dart';
import 'primitives.dart';
import 'prompts.dart';
import 'theme.dart';
import 'widgets.dart';
import '../voice/voice_scope.dart';
import '../voice/voice_service.dart';
import '../api/client.dart';

// Split out of the original 3719-line chat.dart. Every part below is a verbatim
// line range of that file: a pure move, no logic touched.
part 'chat/chat_page.dart';
part 'chat/chat_transcript.dart';
part 'chat/chat_status.dart';
part 'chat/chat_welcome.dart';
part 'chat/chat_message.dart';
part 'chat/chat_reply_meta.dart';
part 'chat/chat_message_actions.dart';
part 'chat/chat_composer.dart';
part 'chat/chat_agent_sheets.dart';
part 'chat/chat_send_button.dart';
part 'chat/chat_voice_strip.dart';
part 'chat/chat_input_controls.dart';
part 'chat/chat_file_picker.dart';
part 'chat/chat_run_progress.dart';
