import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../state/store.dart';

// Split out of the original 1354-line voice_service.dart. The types and the VoiceService
// class body are moved verbatim; its methods live in VoiceService* extensions (statics
// are written VoiceService.name there).
part 'voice_service/voice_service_types.dart';
part 'voice_service/voice_service_core.dart';
part 'voice_service/voice_service_state.dart';
part 'voice_service/voice_service_settings.dart';
part 'voice_service/voice_service_lifecycle.dart';
part 'voice_service/voice_service_dictation.dart';
part 'voice_service/voice_service_conversation.dart';
part 'voice_service/voice_service_speech.dart';
