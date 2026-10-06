part of '../models.dart';

Map<String, dynamic> asMap(dynamic v) => v is Map
    ? v.map((k, val) => MapEntry(k.toString(), val))
    : <String, dynamic>{};

List<dynamic> asList(dynamic v) => v is List ? v : const [];

int asInt(dynamic v, [int d = 0]) => v is int
    ? v
    : (v is num ? v.toInt() : (v is String ? int.tryParse(v) ?? d : d));

String asStr(dynamic v, [String d = '']) => v == null ? d : v.toString();

double asDouble(dynamic v, [double d = 0]) =>
    v is num ? v.toDouble() : (v is String ? double.tryParse(v) ?? d : d);

bool asBool(dynamic v, [bool d = false]) => v is bool ? v : d;

// ---------- tokens / cost ----------

class Tokens {
  final int input, output, reasoning, cacheRead, cacheWrite;
  Tokens(
    this.input,
    this.output,
    this.reasoning,
    this.cacheRead,
    this.cacheWrite,
  );

  factory Tokens.from(Map<String, dynamic> j) => Tokens(
    asInt(j['input']),
    asInt(j['output']),
    asInt(j['reasoning']),
    asInt(asMap(j['cache'])['read']),
    asInt(asMap(j['cache'])['write']),
  );

  int get total => input + output + reasoning;

  String get pretty => [
    if (input > 0) 'in $input',
    if (output > 0) 'out $output',
    if (reasoning > 0) 'think $reasoning',
    if (cacheRead > 0) 'cache ${cacheRead ~/ 1024}k',
  ].join(' · ');
}

class SessionSummary {
  final int additions, deletions, files;
  SessionSummary(this.additions, this.deletions, this.files);
  factory SessionSummary.from(Map<String, dynamic> j) => SessionSummary(
    asInt(j['additions']),
    asInt(j['deletions']),
    asInt(j['files']),
  );
  static final zero = SessionSummary(0, 0, 0);
}

// ---------- pending prompt queue ----------

/// One entry in the pending-prompt queue.
///
/// Permissions and questions are fetched from two different endpoints and
/// arrive on two different lists, but a human only ever answers them one at a
/// time, in the order they were asked. Keeping them in a single ordered queue
/// is what stops a steady stream of tool permissions from starving a question
/// that was asked first: the overlay shows whichever request has been waiting
/// longest, not whichever kind happens to sit in the first list.
class PendingPrompt {
  /// Monotonic arrival stamp. Assigned by the store the first time a request id
  /// is seen and deliberately *not* reassigned on resync, so a reconnect cannot
  /// reshuffle a queue the user is part-way through.
  final int seq;

  /// Exactly one of these is non-null.
  final PermissionReq? permission;
  final QuestionReq? question;

  /// Public because the store builds these: a private constructor would make
  /// the queue unconstructable from the only place that populates it.
  const PendingPrompt(this.seq, this.permission, this.question);

  String get id => permission?.id ?? question?.id ?? '';

  bool get isPermission => permission != null;

  bool get isQuestion => question != null;
}

// ---------- session ----------

class Session {
  final String id;
  final String title;
  final String directory;
  final String parentId;
  final int created, updated;
  final double cost;
  final Tokens tokens;
  final SessionSummary summary;
  final String agent;
  final String providerId, modelId;
  final String shareUrl;
  final Map<String, dynamic> raw;

  Session({
    required this.id,
    required this.title,
    required this.directory,
    required this.parentId,
    required this.created,
    required this.updated,
    required this.cost,
    required this.tokens,
    required this.summary,
    required this.agent,
    required this.providerId,
    required this.modelId,
    required this.shareUrl,
    required this.raw,
  });

  factory Session.fromJson(Map<String, dynamic> j) {
    final t = asMap(j['time']);
    final m = asMap(j['model']);
    return Session(
      id: asStr(j['id']),
      title: asStr(j['title'], 'Untitled'),
      directory: asStr(j['directory']),
      parentId: asStr(j['parentID']),
      created: asInt(t['created']),
      updated: asInt(t['updated']),
      cost: asDouble(j['cost']),
      tokens: Tokens.from(asMap(j['tokens'])),
      summary: j['summary'] == null
          ? SessionSummary.zero
          : SessionSummary.from(asMap(j['summary'])),
      agent: asStr(j['agent']),
      providerId: asStr(m['providerID']),
      modelId: asStr(m['id'], asStr(m['modelID'])),
      shareUrl: asStr(asMap(j['share'])['url']),
      raw: j,
    );
  }

  bool get isChild => parentId.isNotEmpty;
  bool get isShared => shareUrl.isNotEmpty;

  String get label => title.trim().isEmpty ? id : title.trim();

  Map<String, dynamic> toMap() => raw;
}

// ---------- message ----------

class Message {
  final String id, sessionId, role, parentId, agent, providerId, modelId;
  final int created;
  final double cost;
  final Tokens tokens;
  final String finishReason;
  final String summaryText;
  final bool summary;
  final Map<String, dynamic> raw;

  Message({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.parentId,
    required this.agent,
    required this.providerId,
    required this.modelId,
    required this.created,
    required this.cost,
    required this.tokens,
    required this.finishReason,
    required this.summaryText,
    required this.summary,
    required this.raw,
  });

  factory Message.fromJson(Map<String, dynamic> j) {
    final m = asMap(j['model']);
    return Message(
      id: asStr(j['id']),
      sessionId: asStr(j['sessionID']),
      role: asStr(j['role'], 'assistant'),
      parentId: asStr(j['parentID']),
      agent: asStr(j['agent']),
      providerId: asStr(m['providerID'], asStr(j['providerID'])),
      modelId: asStr(m['modelID'], asStr(j['modelID'])),
      created: asInt(asMap(j['time'])['created']),
      cost: asDouble(j['cost']),
      tokens: Tokens.from(asMap(j['tokens'])),
      finishReason: asStr(asMap(j['finish'])['reason']),
      summaryText: asStr(asMap(j['summary'])['summary']),
      // Only a literal `true` is a compaction summary. User messages can carry
      // a `summary` *object*, and treating that as a summary made them vanish
      // from the chat after a reload.
      summary: j['summary'] == true,
      raw: j,
    );
  }

  bool get isUser => role == 'user';
  bool get isError => finishReason == 'error' || raw['error'] != null;

  /// True once the server stamped a completion time on this message. A stopped
  /// or failed run can leave `finish` empty, so this is the only reliable
  /// "generation actually ended" signal.
  bool get completed => asInt(asMap(raw['time'])['completed']) > 0;

  /// Error the server attached to this message, as displayable text.
  /// Aborted / failed runs set `error` and never set a finish reason, which is
  /// why the raw message needs this before the UI can show anything.
  String? get errorMessage {
    final e = raw['error'];
    if (e == null) return null;
    if (e is String) return e.trim().isEmpty ? null : e.trim();
    final m = e is Map<String, dynamic> ? e : const <String, dynamic>{};
    final data = asMap(m['data']);
    final msg = asStr(data['message'], asStr(m['message'])).trim();
    if (msg.isNotEmpty) return msg;
    final name = asStr(m['name']).trim();
    return name.isEmpty ? null : name;
  }

  Map<String, dynamic> toMap() => raw;
}

// ---------- parts ----------

enum ToolStatus { pending, running, completed, error, unknown }

class Part {
  final String id, messageId, sessionId, type;
  final String text;
  final String toolName, toolCallId, toolStatusRaw;
  final String title, output, errorText;
  final Map<String, dynamic> toolInput, toolMeta;
  final int toolStart, toolEnd;
  final String filename, mime, url;
  final String subtaskAgent;
  final String patchText;
  final String reason;
  final bool synthetic;
  final Map<String, dynamic> raw;

  Part({
    required this.id,
    required this.messageId,
    required this.sessionId,
    required this.type,
    required this.text,
    required this.toolName,
    required this.toolCallId,
    required this.toolStatusRaw,
    required this.title,
    required this.output,
    required this.errorText,
    required this.toolInput,
    required this.toolMeta,
    required this.toolStart,
    required this.toolEnd,
    required this.filename,
    required this.mime,
    required this.url,
    required this.subtaskAgent,
    required this.patchText,
    required this.reason,
    required this.synthetic,
    required this.raw,
  });

  factory Part.fromJson(Map<String, dynamic> j) {
    final st = asMap(j['state']);
    final meta = asMap(st['metadata']);
    final tm = asMap(j['time']);
    return Part(
      id: asStr(j['id']),
      messageId: asStr(j['messageID']),
      sessionId: asStr(j['sessionID']),
      type: asStr(j['type'], 'text'),
      text: asStr(j['text']),
      toolName: asStr(j['tool']),
      toolCallId: asStr(j['callID']),
      toolStatusRaw: asStr(
        st['status'],
        j['status'] == null ? '' : asStr(j['status']),
      ),
      title: asStr(st['title'], asStr(j['title'])),
      output: asStr(st['output'], asStr(meta['output'])),
      errorText: asStr(st['error']),
      toolInput: asMap(st['input']),
      toolMeta: meta,
      toolStart: asInt(tm['start']),
      toolEnd: asInt(tm['end']),
      filename: asStr(j['filename']),
      mime: asStr(j['mime']),
      url: asStr(j['url']),
      subtaskAgent: asStr(j['agent']),
      patchText: asStr(j['patch'], asStr(j['text'])),
      reason: asStr(j['reason']),
      synthetic: asBool(j['synthetic']),
      raw: j,
    );
  }

  ToolStatus get status {
    switch (toolStatusRaw) {
      case 'pending':
        return ToolStatus.pending;
      case 'running':
        return ToolStatus.running;
      case 'completed':
        return ToolStatus.completed;
      case 'error':
        return ToolStatus.error;
      default:
        return ToolStatus.unknown;
    }
  }

  int? get exitCode {
    final v = toolMeta['exit'];
    return v == null ? null : asInt(v);
  }

  bool get truncated => asBool(toolMeta['truncated']);

  /// Human readable one-liner for a tool invocation.
  String get summaryLine {
    if (title.trim().isNotEmpty) return title.trim();
    switch (toolName) {
      case 'bash':
      case 'shell':
        return asStr(toolInput['command'], asStr(toolInput['description']));
      case 'read':
      case 'write':
      case 'edit':
      case 'patch':
        return asStr(toolInput['filePath'], asStr(toolInput['path']));
      case 'grep':
        return 'grep ${asStr(toolInput['pattern'])}';
      case 'glob':
        return 'glob ${asStr(toolInput['pattern'])}';
      case 'list':
        return 'ls ${asStr(toolInput['path'], '.')}';
      case 'webfetch':
      case 'websearch':
        return asStr(toolInput['url'], asStr(toolInput['query']));
      case 'task':
      case 'agent':
        return 'subagent ${asStr(toolInput['subagent_type'], asStr(toolInput['description']))}';
      default:
        if (toolInput.isEmpty) return toolName;
        return '$toolName ${_short(toolInput.toString())}';
    }
  }

  static String _short(String s) {
    final one = s.replaceAll(RegExp(r'\s+'), ' ');
    return one.length <= 80 ? one : '${one.substring(0, 80)}…';
  }

  Map<String, dynamic> toMap() => raw;
}

// ---------- agent / provider / model ----------

class Agent {
  final String name, description, mode;
  final bool native;
  final List<Map<String, dynamic>> permission;
  Agent({
    required this.name,
    required this.description,
    required this.mode,
    required this.native,
    required this.permission,
  });

  factory Agent.fromJson(Map<String, dynamic> j) => Agent(
    name: asStr(j['name']),
    description: asStr(j['description']),
    mode: asStr(j['mode'], 'all'),
    native: asBool(j['native']),
    permission: asList(j['permission']).map(asMap).toList(),
  );

  String get modeLabel => switch (mode) {
    'primary' => 'primary',
    'subagent' => 'subagent',
    'all' => 'all',
    _ => mode,
  };
}
