// Data models mirroring the opencode server OpenAPI schemas.
// Verified against opencode 1.18.27 /doc spec.
import 'dart:convert';

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
      summary: j['summary'] != null,
      raw: j,
    );
  }

  bool get isUser => role == 'user';
  bool get isError => finishReason == 'error' || raw['error'] != null;

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

class ModelInfo {
  final String id, name, providerId, family;
  final bool reasoning, attachment, toolcall, temperature;
  final int contextLimit, outputLimit;
  ModelInfo({
    required this.id,
    required this.name,
    required this.providerId,
    required this.family,
    required this.reasoning,
    required this.attachment,
    required this.toolcall,
    required this.temperature,
    required this.contextLimit,
    required this.outputLimit,
  });

  factory ModelInfo.fromJson(
    String providerId,
    String modelId,
    Map<String, dynamic> j,
  ) {
    final cap = asMap(j['capabilities']);
    final lim = asMap(j['limit']);
    return ModelInfo(
      id: asStr(j['id'], modelId),
      name: asStr(j['name'], modelId),
      providerId: providerId,
      family: asStr(j['family']),
      reasoning: asBool(cap['reasoning']),
      attachment: asBool(cap['attachment']),
      toolcall: asBool(cap['toolcall']),
      temperature: asBool(cap['temperature']),
      contextLimit: asInt(lim['context']),
      outputLimit: asInt(lim['output']),
    );
  }

  String get key => '$providerId/$id';
}

// ---------- todo ----------

class Todo {
  final String id, content, status;
  final String priority;
  Todo({
    required this.id,
    required this.content,
    required this.status,
    required this.priority,
  });

  factory Todo.fromJson(Map<String, dynamic> j) => Todo(
    id: asStr(j['id']),
    content: asStr(j['content']),
    status: asStr(j['status'], 'pending'),
    priority: asStr(j['priority'], 'medium'),
  );

  bool get done => status == 'completed';
  bool get active => status == 'in_progress' || status == 'running';
}

// ---------- files ----------

class FileNode {
  final String name, path, absolute, type;
  final bool ignored;
  FileNode({
    required this.name,
    required this.path,
    required this.absolute,
    required this.type,
    required this.ignored,
  });

  factory FileNode.fromJson(Map<String, dynamic> j) => FileNode(
    name: asStr(j['name']),
    path: asStr(j['path']),
    absolute: asStr(j['absolute']),
    type: asStr(j['type'], 'file'),
    ignored: asBool(j['ignored']),
  );

  bool get isDir => type == 'directory';
}

class FileDiff {
  final String path, file, additions, deletions, before, after;
  FileDiff({
    required this.path,
    required this.file,
    required this.additions,
    required this.deletions,
    required this.before,
    required this.after,
  });

  factory FileDiff.fromJson(Map<String, dynamic> j) => FileDiff(
    path: asStr(j['path']),
    file: asStr(j['file'], asStr(j['path'])),
    additions: asStr(j['additions']),
    deletions: asStr(j['deletions']),
    before: asStr(j['before']),
    after: asStr(j['after']),
  );

  int get addCount => asInt(additions);
  int get delCount => asInt(deletions);
}

// ---------- command / skill / status ----------

class CommandInfo {
  final String name, description, template, source, agent, model;
  CommandInfo({
    required this.name,
    required this.description,
    required this.template,
    required this.source,
    required this.agent,
    required this.model,
  });

  factory CommandInfo.fromJson(Map<String, dynamic> j) => CommandInfo(
    name: asStr(j['name']),
    description: asStr(j['description']),
    template: asStr(j['template']),
    source: asStr(j['source'], 'command'),
    agent: asStr(j['agent']),
    model: asStr(j['model']),
  );
}

class SkillInfo {
  final String name, description, path;
  SkillInfo({
    required this.name,
    required this.description,
    required this.path,
  });

  factory SkillInfo.fromJson(Map<String, dynamic> j) => SkillInfo(
    name: asStr(j['name']),
    description: asStr(j['description']),
    path: asStr(j['path']),
  );
}

class NamedStatus {
  final String id, name, status, message, detail;
  NamedStatus({
    required this.id,
    required this.name,
    required this.status,
    required this.message,
    required this.detail,
  });

  bool get healthy =>
      status == 'connected' || status == 'ready' || status == 'running';

  factory NamedStatus.fromJson(String key, Map<String, dynamic> j) =>
      NamedStatus(
        id: asStr(j['id'], key),
        name: asStr(j['name'], key),
        status: asStr(j['status']),
        message: asStr(j['message']),
        detail: j['error'] == null ? '' : jsonEncode(j['error']),
      );
}

class VcsInfo {
  final String branch, defaultBranch;
  const VcsInfo({required this.branch, required this.defaultBranch});

  factory VcsInfo.fromJson(Map<String, dynamic> j) => VcsInfo(
    branch: asStr(j['branch']),
    defaultBranch: asStr(j['default_branch']),
  );

  bool get isRepo => branch.isNotEmpty;
}

class ServerPaths {
  final String directory, worktree, home, config, state;
  const ServerPaths({
    required this.directory,
    required this.worktree,
    required this.home,
    required this.config,
    required this.state,
  });

  factory ServerPaths.fromJson(Map<String, dynamic> j) => ServerPaths(
    directory: asStr(j['directory']),
    worktree: asStr(j['worktree']),
    home: asStr(j['home']),
    config: asStr(j['config']),
    state: asStr(j['state']),
  );
}

// ---------- permission / question ----------

class PermissionReq {
  final String id, sessionId, permission;
  final List<String> patterns, always;
  final Map<String, dynamic> metadata;
  final String messageId, callId;
  final Map<String, dynamic> raw;

  PermissionReq({
    required this.id,
    required this.sessionId,
    required this.permission,
    required this.patterns,
    required this.always,
    required this.metadata,
    required this.messageId,
    required this.callId,
    required this.raw,
  });

  factory PermissionReq.fromJson(Map<String, dynamic> j) {
    final t = asMap(j['tool']);
    return PermissionReq(
      id: asStr(j['id']),
      sessionId: asStr(j['sessionID']),
      permission: asStr(j['permission']),
      patterns: asList(j['patterns']).map((e) => e.toString()).toList(),
      always: asList(j['always']).map((e) => e.toString()).toList(),
      metadata: asMap(j['metadata']),
      messageId: asStr(t['messageID']),
      callId: asStr(t['callID']),
      raw: j,
    );
  }

  /// Newer servers emit permission.v2.asked with `action` + `resources`.
  factory PermissionReq.fromV2(Map<String, dynamic> j) {
    final p = asMap(j['properties']);
    return PermissionReq(
      id: asStr(p['id']),
      sessionId: asStr(p['sessionID']),
      permission: asStr(p['action']),
      patterns: asList(p['resources']).map((e) => e.toString()).toList(),
      always: asList(p['save']).map((e) => e.toString()).toList(),
      metadata: asMap(p['metadata']),
      messageId: '',
      callId: '',
      raw: j,
    );
  }

  String get title => permission.isEmpty ? 'Permission' : permission;

  String get detail {
    final md = metadata.entries
        .where((e) => e.value != null && e.key != 'diff')
        .map((e) => '${e.key}: ${_fmt(e.value)}')
        .join('\n');
    final pat = patterns.isEmpty ? '' : patterns.join('\n');
    return [if (pat.isNotEmpty) pat, if (md.isNotEmpty) md].join('\n');
  }

  static String _fmt(dynamic v) => v is String
      ? v
      : v is List
      ? v.join(', ')
      : jsonEncode(v);
}

class QuestionOption {
  final String label, description;
  const QuestionOption(this.label, this.description);
  factory QuestionOption.fromJson(Map<String, dynamic> j) =>
      QuestionOption(asStr(j['label']), asStr(j['description']));
}

class QuestionItem {
  final String header, question;
  final List<QuestionOption> options;
  final bool multiple, custom;
  const QuestionItem({
    required this.header,
    required this.question,
    required this.options,
    required this.multiple,
    required this.custom,
  });

  factory QuestionItem.fromJson(Map<String, dynamic> j) => QuestionItem(
    header: asStr(j['header']),
    question: asStr(j['question']),
    options: asList(j['options'])
        .map((e) => QuestionOption.fromJson(asMap(e)))
        .toList(),
    multiple: asBool(j['multiple']),
    custom: asBool(j['custom']),
  );
}

class QuestionReq {
  final String id, sessionId;
  final List<QuestionItem> questions;
  final Map<String, dynamic> raw;
  const QuestionReq({
    required this.id,
    required this.sessionId,
    required this.questions,
    required this.raw,
  });

  factory QuestionReq.fromJson(Map<String, dynamic> j) {
    final p = asMap(j['properties']);
    final list = p.isEmpty ? asList(j['questions']) : asList(p['questions']);
    return QuestionReq(
      id: asStr(p['id'], asStr(j['id'])),
      sessionId: asStr(p['sessionID'], asStr(j['sessionID'])),
      questions: list.map((e) => QuestionItem.fromJson(asMap(e))).toList(),
      raw: j,
    );
  }
}

// ---------- helpers ----------

String fmtBytes(int n) {
  if (n < 1024) return '$n B';
  if (n < 1024 * 1024) return '${(n / 1024).toStringAsFixed(1)} KB';
  return '${(n / 1024 / 1024).toStringAsFixed(1)} MB';
}

String fmtTime(int ms) {
  if (ms <= 0) return '-';
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  return '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

String fmtAge(int ms) {
  if (ms <= 0) return '';
  final diff = DateTime.now().millisecondsSinceEpoch - ms;
  if (diff < 60000) return 'abhi';
  if (diff < 3600000) return '${diff ~/ 60000}m';
  if (diff < 86400000) return '${diff ~/ 3600000}h';
  if (diff < 604800000) return '${diff ~/ 86400000}d';
  return fmtTime(ms);
}

String fmtDuration(int ms) {
  if (ms <= 0) return '';
  if (ms < 1000) return '${ms}ms';
  if (ms < 60000) return '${(ms / 1000).toStringAsFixed(1)}s';
  final m = ms ~/ 60000;
  return '${m}m ${((ms % 60000) / 1000).round()}s';
}

String baseName(String p) {
  final i = p.lastIndexOf('/');
  return i < 0 ? p : p.substring(i + 1);
}

String dirName(String p) {
  final i = p.lastIndexOf('/');
  if (i < 0) return '.';
  if (i == 0) return '/';
  return p.substring(0, i);
}
