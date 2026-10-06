// ignore_for_file: invalid_use_of_protected_member
part of '../store.dart';

/// History paging, attachments and the send queue.
///
/// Moved out of [OcStore] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [OcStore]; the only edit is that references to its statics read `OcStore.name`.
extension OcStoreHistory on OcStore {
  /// Adds older messages in front of the loaded history, skipping any the
  /// server already gave us, and caches them.
  void _prependHistory(String id, List<ChatMessage> older) {
    if (older.isEmpty) return;
    final known = {for (final m in messages) m.info.id};
    final fresh = older.where((m) => !known.contains(m.info.id)).toList();
    if (fresh.isEmpty) return;
    messages = [...fresh, ...messages];
    // The page is all older turns, so an optimistic bubble still sitting in the
    // list can only have been superseded by a confirmed message already in it.
    OcStore._stripEchoedOptimistic(messages, messages);
    _oldestMessageId = messages.first.info.id;
    _persistHistory(id, fresh);
  }

  /// Fallback for servers that reject `before`: refetch a wider prefix and
  /// splice in the older messages that reveals. Uses only `limit`, which every
  /// build supports, so history stays reachable instead of stopping dead at
  /// the first page.
  Future<void> _widenHistory(String id, [int? gen]) async {
    final wider = (_limit * 4).clamp(
      0,
      5000,
    ); // Cap at 5000 to prevent unbounded growth
    final all = (await api.messages(id, limit: wider))
        .map((e) => ChatMessage(e.info, e.parts))
        .where((m) => !m.info.summary)
        .toList();
    // Guard against session switch during the await.
    if (gen != null && gen != _historyLoadGen) return;
    if (current?.id != id || _disposed) return;
    if (all.length <= messages.length) {
      hasMoreMessages = false;
      return;
    }
    final known = {for (final m in messages) m.info.id};
    final extra = all.where((m) => !known.contains(m.info.id)).toList();
    if (extra.isEmpty) {
      hasMoreMessages = false;
      return;
    }
    _limit = wider;
    _prependHistory(id, extra);
    // A short page means the server had nothing more to give.
    hasMoreMessages = all.length >= wider;
  }

  Future<void> loadOlderMessages() async {
    final id = current?.id;
    final gen = _historyLoadGen;
    if (id == null || _oldestMessageId == null || messagesLoading) return;
    messagesLoading = true;
    notifyListeners();
    try {
      // Preferred path: ask for the page before the oldest message we hold.
      final fetched =
          (await api.messages(id, limit: 60, before: _oldestMessageId))
              .map((e) => ChatMessage(e.info, e.parts))
              .where((m) => !m.info.summary)
              .toList();
      // Guard against session switch during the await.
      if (gen != _historyLoadGen || current?.id != id || _disposed) return;
      if (fetched.isNotEmpty) {
        _prependHistory(id, fetched);
        hasMoreMessages = fetched.length >= 60;
      } else {
        hasMoreMessages = false;
      }
    } on ApiException {
      // `before` is unimplemented on some builds. Widening `limit` recovers the
      // history instead of giving up and hiding it permanently.
      await _widenHistory(id, gen);
    } catch (e) {
      debugPrint('Failed to load older messages: $e');
      // Guard against session switch during the await.
      if (gen != _historyLoadGen || current?.id != id || _disposed) return;
      hasMoreMessages = false;
    }
    if (gen == _historyLoadGen && current?.id == id) {
      messagesLoading = false;
      notifyListeners();
    }
  }

  // =====================================================================
  // prompting
  // =====================================================================

  void addAttachment(PendingAttachment a) {
    attachments.add(a);
    notifyListeners();
  }

  void removeAttachment(int i) {
    if (i >= 0 && i < attachments.length) attachments.removeAt(i);
    notifyListeners();
  }

  void clearAttachments() {
    attachments.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> _partPayload() {
    final parts = <Map<String, dynamic>>[];
    for (final a in attachments) {
      parts.add({
        'type': 'file',
        'mime': a.mime,
        'filename': a.name,
        'url': a.dataUrl,
      });
    }
    return parts;
  }

  List<String> get queued => List.unmodifiable(_queued);
  bool get hasQueued => _queued.isNotEmpty;

  /// Send now, or queue if a run is already in flight.
  Future<void> sendOrQueue(
    String text, {
    List<Map<String, dynamic>> extraParts = const [],
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && extraParts.isEmpty) return;
    if (busy) {
      _queued.add(text);
      notifyListeners();
      return;
    }
    await send(text, extraParts: extraParts);
  }

  /// Sends the next queued prompt. Called when a run ends.
  Future<void> _flushQueue() async {
    if (_queued.isEmpty || busy || _disposed) return;
    final next = _queued.removeAt(0);
    notifyListeners();
    try {
      await send(next);
    } catch (_) {
      // The failure path already surfaced an error bar; keep the rest queued.
      return;
    }
  }

  Future<void> send(
    String text, {
    List<Map<String, dynamic>> extraParts = const [],
  }) async {
    var sid = current?.id;
    if (sid == null) {
      final s = await newSession();
      if (s == null) return;
      sid = s.id;
    }

    final parts = [..._partPayload(), ...extraParts];
    final trimmed = text.trim();
    if (trimmed.isNotEmpty) parts.insert(0, {'type': 'text', 'text': text});
    if (parts.isEmpty) return;
    clearAttachments();

    // Only one prompt is in flight, so the echo hand-over is 1:1. Clearing both
    // here keeps a send the server never echoed from stealing the next echo.
    _clearLocalEcho();
    messages.removeWhere(
      (m) => m.info.raw['optimistic'] == true && m.info.role == 'user',
    );

    // Optimistically add user message for instant feedback
    final userMsgId = 'local-${DateTime.now().millisecondsSinceEpoch}';
    final userMsg = Message(
      id: userMsgId,
      sessionId: sid,
      role: 'user',
      parentId: '',
      agent: agent,
      providerId: providerId,
      modelId: modelId,
      created: DateTime.now().millisecondsSinceEpoch,
      cost: 0,
      tokens: Tokens(0, 0, 0, 0, 0),
      finishReason: '',
      summaryText: '',
      summary: false,
      raw: {'optimistic': true},
    );
    final userParts = parts
        .where((p) => p['type'] == 'text' || p['type'] == 'file')
        .map((p) {
          if (p['type'] == 'text') {
            return Part.fromJson({
              'id': 'part-$userMsgId',
              'messageID': userMsgId,
              'sessionID': sid,
              'type': 'text',
              'text': p['text'],
            });
          } else {
            return Part.fromJson({
              'id': 'part-$userMsgId-${p['filename']}',
              'messageID': userMsgId,
              'sessionID': sid,
              'type': 'file',
              'filename': p['filename'],
              'mime': p['mime'],
              'url': p['url'],
            });
          }
        })
        .toList();
    messages.add(ChatMessage(userMsg, userParts));
    notifyListeners();

    sessionError = null;
    await _sendParts(sid, parts);
  }
}
