part of '../voice_service.dart';

/// A language the recogniser on this device can hear.
///
/// Deliberately not the plugin's `LocaleName`: that type must not reach a widget
/// file, or every screen showing a language list imports a speech package.
class VoiceLocale {
  /// BCP-47-ish id such as `en_US`, which is also what gets stored.
  final String id;

  /// The name the platform reports, e.g. "English (United States)".
  final String name;

  const VoiceLocale({required this.id, required this.name});
}

/// Where the voice stack is right now.
///
/// One enum instead of a pile of booleans, so every asynchronous callback - a
/// recognition result, a synthesiser completion, a store change that lands three
/// seconds late - can be answered with a single question (was that still
/// wanted?) and so the answer is checkable. A transition that is not in
/// [_allowed] is refused, which is what makes a stale platform callback
/// harmless: it cannot drag a finished session back into `listening`.
enum VoicePhase {
  /// Nothing holds the microphone or the speaker.
  idle,

  /// The recogniser is starting and may be showing the OS microphone prompt.
  requestingPermission,

  /// The microphone is open. [VoiceService.partial] is what has been heard.
  listening,

  /// A final result is in and is being committed: inserted, or sent.
  processing,

  /// Reading a reply aloud. [VoiceService.spokenIndex] tracks the queue.
  speaking,

  /// Hands-free: the prompt was sent and the reply has not landed yet.
  waiting,

  /// Stopped on a failure. [VoiceService.failure] says which one.
  error,

  /// No recogniser or no speech engine on this device.
  unavailable,
}

/// Why voice stopped, in terms the UI turns into one calm sentence.
enum VoiceFailure {
  /// The microphone is not granted and Android will not ask again.
  permission,

  /// No speech recognition service is installed or reachable.
  recognizer,

  /// Nothing was said before the silence timeout.
  noSpeech,

  /// The link dropped while listening, or while waiting for the server.
  network,

  /// The recogniser refused to start: something else owns the microphone.
  busy,

  /// The chosen language is not available on this device.
  language,

  /// The model that would answer has not been picked yet.
  noModel,

  /// The text-to-speech engine refused, or there is none.
  playback,

  /// Hands-free needs to send what it hears, and auto-send is off.
  autoSendOff,

  /// Unclassified. Never surfaced raw.
  unknown,
}

/// The whole state machine. Anything not listed here cannot happen.
///
/// Two entries earn their keep. `listening` cannot reach `speaking` directly, so
/// a reply cannot be read into the microphone; [VoiceService.speak] detours
/// through `idle` first. And nothing reaches [VoicePhase.listening] from
/// `error` without going past the recogniser check, so a failed attempt cannot
/// leave a half-started engine behind.
const Map<VoicePhase, Set<VoicePhase>> _allowed =
    <VoicePhase, Set<VoicePhase>>{
      VoicePhase.idle: <VoicePhase>{
        VoicePhase.requestingPermission,
        VoicePhase.listening,
        VoicePhase.speaking,
        VoicePhase.error,
        VoicePhase.unavailable,
      },
      VoicePhase.requestingPermission: <VoicePhase>{
        VoicePhase.listening,
        VoicePhase.idle,
        VoicePhase.error,
        VoicePhase.unavailable,
      },
      VoicePhase.listening: <VoicePhase>{
        VoicePhase.processing,
        VoicePhase.idle,
        VoicePhase.error,
      },
      VoicePhase.processing: <VoicePhase>{
        VoicePhase.idle,
        VoicePhase.speaking,
        VoicePhase.waiting,
        VoicePhase.listening,
        VoicePhase.error,
      },
      VoicePhase.speaking: <VoicePhase>{
        VoicePhase.idle,
        VoicePhase.listening,
        VoicePhase.error,
      },
      VoicePhase.waiting: <VoicePhase>{
        VoicePhase.speaking,
        VoicePhase.listening,
        VoicePhase.idle,
        VoicePhase.error,
      },
      VoicePhase.error: <VoicePhase>{
        VoicePhase.idle,
        VoicePhase.requestingPermission,
        VoicePhase.listening,
        VoicePhase.speaking,
        VoicePhase.unavailable,
      },
      VoicePhase.unavailable: <VoicePhase>{
        VoicePhase.idle,
        VoicePhase.requestingPermission,
      },
    };
