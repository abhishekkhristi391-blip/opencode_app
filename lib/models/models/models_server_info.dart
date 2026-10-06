part of '../models.dart';

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

  /// Dropped by the agent. Not a completion, so it is kept out of the "done"
  /// count rather than inflating progress, and out of "pending" too — the server
  /// documents `cancelled` alongside pending/in_progress/completed, and showing
  /// it as still-to-do is the one thing that would be a lie.
  bool get cancelled => status == 'cancelled';
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
  ///
  /// Verified against opencode 1.18.27's `EventPermissionV2Asked`: the request
  /// fields sit directly in the event's `properties`, i.e. they *are* the map
  /// the store already holds. Unwrapping `properties` again (as this used to)
  /// yielded an empty map, so every v2 request parsed to an empty id and was
  /// then dropped by the store's `id.isNotEmpty` guard — a silently invisible
  /// approval. Both shapes are therefore accepted: unwrapped, or nested.
  factory PermissionReq.fromV2(Map<String, dynamic> j) {
    final nested = asMap(j['properties']);
    final p = nested.isEmpty ? j : nested;
    final src = asMap(p['source']);
    return PermissionReq(
      id: asStr(p['id']),
      sessionId: asStr(p['sessionID']),
      permission: asStr(p['action']),
      patterns: asList(p['resources']).map((e) => e.toString()).toList(),
      always: asList(p['save']).map((e) => e.toString()).toList(),
      metadata: asMap(p['metadata']),
      messageId: asStr(src['messageID']),
      callId: asStr(src['callID']),
      raw: j,
    );
  }

  String get title => permission.isEmpty ? 'Permission' : permission;

  /// The tool that raised the request, when the server says so. v2 puts it in
  /// `metadata.tool` as a string; v1 has no field for it at all.
  String get tool {
    final t = metadata['tool'];
    if (t is String) return t;
    if (t is Map && t['name'] is String) return t['name'] as String;
    return '';
  }

  /// The exact command about to run. Only bash-style permissions carry one, and
  /// the user is approving *this* string, so it is shown verbatim and uncut
  /// rather than folded into the generic metadata dump.
  String get command {
    final c = metadata['command'];
    if (c is String) return c;
    if (c is List) return c.join(' ');
    return '';
  }

  /// The directories an external-directory request covers, when present.
  List<String> get directories =>
      asList(metadata['directories']).map((e) => e.toString()).toList();

  /// One line naming what is being approved: the tool if the server said, else
  /// the first pattern or directory, else the permission kind. Used where a
  /// single short label is needed — the working strip's second line.
  String get subject {
    if (tool.isNotEmpty) return tool;
    if (patterns.isNotEmpty) return patterns.first;
    if (directories.isNotEmpty) return directories.first;
    return title;
  }

  /// True when the pattern is so wide that "always" means "always, everywhere".
  /// `/*` on an external-directory request would grant the whole filesystem, and
  /// a user who taps Allow always on that deserves to have been told first.
  bool get isBroadPattern {
    bool broad(String p) {
      final t = p.trim();
      return t == '/*' ||
          t == '*' ||
          t == '/**' ||
          t == '~/*' ||
          t.endsWith('/*') ||
          t.endsWith('/**') ||
          t.startsWith('*:');
    }

    return patterns.any(broad) || always.any(broad);
  }

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

  /// Accepts the same two shapes as [PermissionReq.fromV2]: the request fields
  /// directly (the event's `properties`, which is what 1.18.27 sends), or the
  /// whole envelope with the payload nested one level deeper.
  factory QuestionReq.fromJson(Map<String, dynamic> j) {
    final nested = asMap(j['properties']);
    final p = nested.isEmpty ? j : nested;
    return QuestionReq(
      id: asStr(p['id'], asStr(j['id'])),
      sessionId: asStr(p['sessionID'], asStr(j['sessionID'])),
      questions: asList(p['questions'])
          .map((e) => QuestionItem.fromJson(asMap(e)))
          .toList(),
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
