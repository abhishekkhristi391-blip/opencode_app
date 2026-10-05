part of '../store.dart';

class ChatMessage {
  Message info;
  List<Part> parts;
  String? errorText;

  /// Set once the store has concluded the run is over even though the server
  /// never sent a completion stamp for this message (abort, error, or a lost
  /// `message.updated`). Without it `streaming` stays true and the typing dots
  /// spin forever on a message the agent already abandoned.
  bool settled = false;

  // FIX: always copy into a *growable* list. Passing `const []` used to make
  // parts.add() throw, so streamed parts never showed up.
  ChatMessage(this.info, List<Part> parts, {this.errorText})
    : parts = List<Part>.of(parts);

  /// Error to show for this message: an explicit local one wins over whatever
  /// the server attached.
  String? get displayError => errorText ?? info.errorMessage;

  /// True only while the server is still producing this assistant message.
  /// `time.completed` is checked as well as the finish reason: a stopped or
  /// failed run leaves the finish reason empty, which used to keep the typing
  /// dots on forever and hide the error.
  bool get streaming =>
      !settled &&
      info.finishReason.isEmpty &&
      !info.completed &&
      info.role == 'assistant' &&
      displayError == null;
}

class PendingAttachment {
  final String path, mime, name;
  final int size;
  final String dataUrl;
  PendingAttachment({
    required this.path,
    required this.mime,
    required this.name,
    required this.size,
    required this.dataUrl,
  });
}

/// Single source of truth for the whole app. A [ChangeNotifier] wired into the
/// widget tree through [AppScope], so no external state-management dependency.
/// Transcript-local rebuild signal.
///
/// Token streaming rewrites [OcStore.messages] many times a second. Firing the
/// single app-wide [ChangeNotifier] that often rebuilt *every* mounted
/// subscriber on each token — the composer, the sessions tab kept alive in the
/// `IndexedStack`, the busy and error bars — even though only the transcript
/// displays the text. This carries that traffic instead.
class MessageListSignal extends ChangeNotifier {
  /// Announces a change to the message list.
  ///
  /// Wrapped in its own type so only the store can raise it;
  /// `ChangeNotifier.notifyListeners` is `@protected`.
  void notify() => notifyListeners();
}

/// Todos-section rebuild signal.
///
/// `todo.updated` fires several times per second while an agent walks its list.
/// Going through the app-wide notifier for that rebuilt the whole shell — and
/// with it the transcript, which is the most expensive widget in the app and has
/// nothing to do with a checklist. Only the Tasks page and the two badges read
/// this.
class TodoListSignal extends ChangeNotifier {
  void notify() => notifyListeners();
}
