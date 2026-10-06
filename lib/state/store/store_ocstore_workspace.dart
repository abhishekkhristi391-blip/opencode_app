// ignore_for_file: invalid_use_of_protected_member
part of '../store.dart';

/// Utility session, shell, file operations, config and MCP.
///
/// Moved out of [OcStore] verbatim. It is an extension, so every call site and every
/// private-field access stays as it was. The fields and static helpers stay on
/// [OcStore]; the only edit is that references to its statics read `OcStore.name`.
extension OcStoreWorkspace on OcStore {
  Future<String> _utilSession() async {
    if (_utilSessionId != null) {
      try {
        await api.session(_utilSessionId!);
        return _utilSessionId!;
      } catch (e) {
        debugPrint('Util session validation failed: $e');
        _utilSessionId = null;
      }
    }
    final existing = sessions
        .where((s) => s.title == OcStore.utilSessionTitle)
        .firstOrNull;
    if (existing != null) {
      _utilSessionId = existing.id;
      return existing.id;
    }
    final s = await api.createSession(title: OcStore.utilSessionTitle);
    _utilSessionId = s.id;
    if (!_disposed) unawaited(refreshSessions());
    return s.id;
  }

  Future<({int exit, String output})> runShell(String command) async {
    final sid = await _utilSession();
    final r = await api.shell(sid, command: command, agent: agent);
    var out = '';
    var code = 0;
    var ran = false;
    for (final p in r.parts) {
      if (p.type != 'tool') continue;
      ran = true;
      // A later part succeeding must never mask an earlier failure, otherwise
      // `writeFile` reports success for a half-applied command.
      final e = p.exitCode ?? 0;
      if (e != 0) code = e;
      // Tool-level failure with no `exit` in metadata still has to fail.
      if (e == 0 && p.status == ToolStatus.error) code = 1;
      final stdout = p.output;
      final stderr = p.errorText;
      if (stdout.isNotEmpty) {
        out += (out.isEmpty ? '' : '\n') + stdout;
      }
      if (stderr.isNotEmpty) {
        out += (out.isEmpty ? '' : '\n') + stderr;
      }
    }
    if (!ran) {
      // No tool part at all: the server never executed anything. Returning 0
      // here is exactly what made writes/deletes fail *silently*.
      return (exit: 127, output: out.isEmpty ? S.shellNoOutput : out);
    }
    return (exit: code, output: out);
  }

  Future<void> writeFile(String path, String content) async {
    // No app-side storage permission gate: the file is written by the SERVER
    // (its own shell), not by this app's process. Asking for
    // MANAGE_EXTERNAL_STORAGE here blocked saves for no reason — the failure
    // that matters is the server's, and it surfaces as a shell error below.
    final b64 = base64Encode(utf8.encode(content));
    // Chunked so very large files stay inside ARG_MAX.
    const chunk = 24000;
    final chunks = <String>[];
    for (var i = 0; i < b64.length; i += chunk) {
      chunks.add(b64.substring(i, min(i + chunk, b64.length)));
    }
    final q = OcStore._shellQuote(path);
    final dir = OcStore._shellQuote(OcStore._parentDir(path));
    // Decode into a sibling temp file, then `mv` it into place:
    //  - `mkdir -p` so a not-yet-existing folder is not a silent failure
    //  - `: > $tmp` truncates any leftover temp from an earlier failed write
    //    (appending to it used to prepend garbage to the new content)
    //  - the temp is always created, so an empty file also succeeds
    //  - `mv` is atomic: the original is only replaced once the new content is
    //    fully decoded, so a failed save can never destroy what was there
    final tmp = '$q.oc-tmp';
    var cmd = 'mkdir -p $dir && : > $tmp';
    for (final c in chunks) {
      cmd += " && printf '%s' '$c' >> $tmp";
    }
    cmd += ' && base64 -d $tmp > $tmp.oc-out && mv $tmp.oc-out $q';
    cmd += ' && rm -f $tmp && test -f $q';
    final r = await runShell(cmd);
    if (r.exit != 0) {
      // Best-effort cleanup so a failed save leaves no temp litter behind.
      unawaited(runShell('rm -f $tmp $tmp.oc-out'));
      throw ApiException(
        1,
        'WriteFailed',
        r.output.isEmpty ? 'Write fail: $path' : r.output,
      );
    }
  }

  Future<void> deleteEntry(String path) async {
    final r = await runShell('rm -rf ${OcStore._shellQuote(path)}');
    if (r.exit != 0) {
      throw ApiException(
        1,
        'DeleteFailed',
        r.output.isEmpty ? S.filesDeleteFailed(path) : r.output,
      );
    }
  }

  Future<void> mkdirEntry(String path) async {
    final r = await runShell('mkdir -p ${OcStore._shellQuote(path)}');
    if (r.exit != 0) {
      throw ApiException(
        1,
        'MkdirFailed',
        r.output.isEmpty ? S.filesFolderFailed(path) : r.output,
      );
    }
  }

  // =====================================================================
  // commands / config / mcp
  // =====================================================================

  Future<void> refreshCommands() async {
    try {
      commands = await api.commands();
      skills = await api.skills();
    } catch (e) {
      debugPrint('Failed to refresh commands: $e');
    }
    notifyListeners();
  }

  Future<void> refreshConfig() async {
    try {
      config = await api.config();
      mcp = await api.mcp();
      lsp = await api.lsp();
      formatters = await api.formatters();
    } catch (e) {
      debugPrint('Failed to refresh config: $e');
    }
    notifyListeners();
  }

  Future<void> saveConfig(Map<String, dynamic> patch) async {
    try {
      config = await api.patchConfig(patch);
      _toast(S.configSaved);
    } on ApiException catch (e) {
      _toast(e.message);
    }
    notifyListeners();
  }

  /// Enables server config to allow tools to access directories outside the workspace.
  Future<void> enableExternalDirectoryAccess() async {
    try {
      await api.patchConfig({
        'permission': {
          'edit': 'allow',
          'bash': 'allow',
          'external_directory': 'allow',
        },
      });
      await refreshConfig();
      _toast(S.externalPermEnabled);
    } on ApiException catch (e) {
      _toast(e.message);
    }
  }

  Future<void> addMcp(
    String name,
    String type,
    String value,
    List<String> args,
  ) async {
    try {
      final cfg = type == 'remote'
          ? {'type': 'remote', 'url': value, 'enabled': true}
          : {
              'type': 'local',
              'command': [value, ...args],
              'enabled': true,
            };
      await api.mcpAdd(name, cfg);
      mcp = await api.mcp();
      _toast(S.added(name));
    } on ApiException catch (e) {
      _toast(e.message);
    }
    notifyListeners();
  }
}
