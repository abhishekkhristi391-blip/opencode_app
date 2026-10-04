/// Every user-facing string in the app lives here.
///
/// Rules:
///  * one language only (English) — no mixed Hinglish
///  * no string literals inside widgets; widgets read from this file
///  * interpolated values are exposed as functions, never inline templates
library;

class S {
  const S._();

  // ------------------------------------------------------------------
  // app
  // ------------------------------------------------------------------
  static const appName = 'OpenCode';
  static const appVersion = '1.18.27';

  // ------------------------------------------------------------------
  // generic actions
  // ------------------------------------------------------------------
  static const cancel = 'Cancel';
  static const ok = 'OK';
  static const yes = 'Yes';
  static const save = 'Save';
  static const saving = 'Saving…';
  static const saved = 'Saved';
  static const close = 'Close';
  static const copy = 'Copy';
  static const copied = 'Copied';
  static const copyAll = 'Copy all';
  static const delete = 'Delete';
  static const rename = 'Rename';
  static const retry = 'Retry';
  static const retrying = 'Retrying…';
  static const refresh = 'Refresh';
  static const apply = 'Apply';
  static const skip = 'Skip';
  static const allow = 'Allow';
  static const always = 'Always';
  static const deny = 'Deny';
  static const connect = 'Connect';
  static const disconnect = 'Disconnect';
  static const reconnect = 'Reconnect';
  static const search = 'Search';
  static const showMore = 'Show more';
  static const showLess = 'Show less';
  static const done = 'Done';
  static const loading = 'Loading…';
  static const empty = 'Nothing here';
  static const all = 'All';
  static const none = 'None';
  static const optional = 'optional';
  static const unknown = 'Unknown';
  static const wrap = 'Wrap';
  static const exit = 'Exit';
  static const output = 'Output';
  static const thinking = 'Thinking';

  /// Placeholder used wherever a value is unavailable.
  static const dash = '—';

  // ------------------------------------------------------------------
  // navigation
  // ------------------------------------------------------------------
  static const navChat = 'Chat';
  static const navSessions = 'History';
  static const navFiles = 'Files';
  static const navTerminal = 'Terminal';
  static const navMore = 'More';
  static const navDiff = 'Diff';
  static const navTasks = 'Tasks';
  static const navCommands = 'Commands';
  static const navModels = 'Models';
  static const navSettings = 'Settings';
  static const navAbout = 'About';

  // ------------------------------------------------------------------
  // connection / shell
  // ------------------------------------------------------------------
  static const connecting = 'Connecting to the OpenCode server';
  static const connectionFailedTitle = 'Cannot reach the server';
  static const connectionFailedHint =
      'Run the server in Termux. Start it from the same project folder '
      'you want to browse in the app.';
  static const serverSetupTitle = 'Start the server in Termux';
  static const serverSetupCommand =
      'cd <project-folder>\n'
      'opencode serve --port 4096\n\n'
      '# run it in the background:\n'
      'nohup opencode serve --port 4096 &';
  static const serverSetupNote =
      'The server must run from the project folder — the file browser and '
      'the diff read from that folder.';
  static const serverOnline = 'Connected';
  static const serverOffline = 'Offline';
  static const serverRestartTitle = 'Restart the server instance?';
  static const serverRestartBody =
      'The current instance is disposed and a fresh one is started. '
      'Running work may stop.';
  static const serverRestartAction = 'Restart instance';
  static const serverRestartDone = 'Server restarted';
  static const serverUpstreamTitle = 'Update opencode on the server';
  static const serverUpstreamBody =
      'Bring the server-side opencode to the latest version.';
  static const serverUpgradeAction = 'Upgrade';
  static const serverUpgradeDone = 'Upgrade complete';
  static const serverUpgradeTitle = 'Upgrade opencode?';
  static const gitBranch = 'git: %s';
  static const gitNone = 'git: not a repository';

  static String serverOnlineVersion(String version) =>
      version.isEmpty ? serverOnline : '$serverOnline · v$version';

  // ------------------------------------------------------------------
  // about
  // ------------------------------------------------------------------
  static const aboutVersion = 'Version';
  static const aboutStatus = 'Connection';
  static const aboutServer = 'Server version';
  static const aboutEndpoint = 'Endpoint';
  static const aboutProject = 'Project folder';
  static const aboutBranch = 'Git branch';
  static const aboutCommandsHint = 'Slash commands available in the composer';
  static const aboutModelsHint =
      'Pick the model and agent used for new messages';
  static const aboutSettingsHint = 'Server, providers, MCP and config';
  static const aboutDescription =
      'A Material 3 client for the OpenCode server. Runs the full session '
      'list, files, diff, tasks and terminal of your workspace.';

  // ------------------------------------------------------------------
  // chat
  // ------------------------------------------------------------------
  static const newChat = 'New chat';
  static const chatNoSessionTitle = 'No session yet';
  static const chatNoSessionBody = 'Start a chat first.';
  static const chatPlaceholder = 'Message…';
  static const chatAttachTooltip = 'Attach or run a slash command';
  static const chatSendTooltip = 'Send message';
  static const chatStopTooltip = 'Stop generating';
  static const chatNewChatTooltip = 'New chat';
  static const chatRenameTooltip = 'Rename session';
  static const chatDiffTooltip = 'Open diff';
  static const chatTasksTooltip = 'Open tasks';
  static const chatLoading = 'Loading messages';
  static const chatLoadOlder = 'Load older messages';
  static const chatWelcomeTitle = 'What should we build?';

  /// `chatWelcomeSubtitle` ("Model x/y - agent build") and
  /// `chatWelcomeEmptySubtitle` are gone: both strings now live in the two
  /// chips below, so nothing renders them any more.
  static const chatWelcomeHint =
      'Describe a change and we’ll make it. Or start from a card below.';

  /// Outlined chips under the headline. Replacing one muted sentence that read
  /// "Model x/y · agent z": the identifiers were too long to scan, wrapped on
  /// narrow screens, and were the only place the current model was visible.
  static const chatChipModel = 'Model';
  static const chatChipMode = 'Mode';
  static const chatLoadOlderFailed = 'Could not load older messages';

  static const chatSuggestionStructure =
      'Explain this project structure briefly';
  static const chatSuggestionTests = 'Run the tests and explain failures';
  static const chatSuggestionTodo = 'Find the biggest TODO in the repo';
  static const chatSuggestionPlan = 'Draft a plan for a new feature';

  // Cards are title-only on purpose. "Run the tests and explain failures" already
  // said "explain failures", so the subtitle repeated the card it sat under.

  // Header.
  static const headerReconnecting = 'Reconnecting';

  // Header.
  static const headerTasks = 'Tasks';
  static const headerNewChat = 'New chat';
  static const headerMore = 'More';
  static const headerConnected = 'Connected';
  static const headerOffline = 'Offline';

  // Project / workspace bar.
  static const projectNoBranch = 'No git branch';
  static const projectDetailsTitle = 'Workspace';
  static const projectDirectory = 'Directory';
  static const projectWorktree = 'Worktree';
  static const projectBranch = 'Branch';
  static const projectUnknown = 'Unknown';

  // Composer.
  static const composerModelPill = 'Model and agent';
  static String composerModelAgent(String model, String agent) =>
      '$model · $agent';
  static const composerVoiceTooltip = 'Voice chat';
  static const composerAttachTooltip = 'Attach a file or image';

  // Tool-call timeline.
  static const toolOutputShow = 'Show output';
  static String toolRunning(String name) => 'Running $name';
  static String toolDone(String name) => '$name finished';

  // More sheet.
  static const moreSheetTitle = 'Menu';
  static const moreModel = 'Model';
  static const moreAgent = 'Agent';
  static const moreTools = 'Tools';
  static String moreToolsCount(int n) =>
      n == 0 ? 'All tools enabled' : '$n enabled';
  static const moreVoiceChat = 'Voice chat';
  static const moreChatHistory = 'Chat history';
  static const moreSettings = 'Settings and token usage';
  static const moreAbout = 'About';
  static const moreCommands = 'Commands';

  // Jump-to-latest.
  static const jumpToLatest = 'Jump to latest';

  // Long-press message menu.
  static const messageMenuTitle = 'Message';
  static const messageCopy = 'Copy';
  static const messageUndo = 'Undo';

  static const chipModel = 'Model';
  static const chipPickModel = 'Pick a model';
  static const chipAgent = 'Agent';
  static const chipTools = 'Tools';
  static const chipToolsAll = 'All tools enabled';
  static const chipHideRow = 'Hide options';
  static const chipShowRow = 'Show options';

  static const attachSheetTitle = 'Attach';
  static const attachImage = 'Attach an image';
  static const attachFile = 'Send a file';
  static const attachFileHint = 'Pick a file from the project';
  static const attachSlash = 'Slash command';

  static const toolsSheetTitle = 'Tools';
  static const toolsSheetReset = 'Enable all';
  static const toolsSheetHint =
      'Nothing selected means every tool is enabled (default).';

  static const messageCopied = 'Message copied';
  static const messageForked = 'Fork created';
  static const messageForkHere = 'Fork from here';
  static const messageRevert = 'Revert';
  static const messageDeleteTitle = 'Delete this message?';
  static const messageDeleteBody =
      'The message and all of its parts are removed.';
  static const sessionDeleteTitle = 'Delete this session?';
  static const modelMissing = 'Pick a model first';
  static const sessionNotLoaded = 'This session could not be loaded';

  static String filesCount(int n) => '$n files';
  static String messageCount(int n) => '$n messages';
  static String tokensUsed(int n) => '$n tokens';

  // ------------------------------------------------------------------
  // sessions
  // ------------------------------------------------------------------
  static const sessionsTitle = 'Sessions';
  static const sessionsFilterMain = 'Main';
  static const sessionsFilterAll = 'All';
  static const sessionsLoading = 'Loading sessions';
  static const sessionsErrorTitle = 'Sessions could not be loaded';
  static const sessionsEmptyTitle = 'No sessions yet';
  static const sessionsEmptyBody = 'Start a new chat to create one.';
  static const sessionsFilteredEmptyTitle = 'No sessions in this filter';
  static const sessionsFilteredEmptyBody =
      'Switch to All to include child sessions.';
  static const sessionsRename = 'Rename session';
  static const sessionsFork = 'Fork session';
  static const sessionsForkHint = 'New session with the same history';
  static const sessionsChildren = 'Show child sessions';
  static const sessionsChildrenEmptyTitle = 'No child sessions';
  static const sessionsChildrenEmptyBody =
      'This session has no subagent sessions.';
  static const sessionsUnshare = 'Remove share link';
  static const sessionsShare = 'Create share link';
  static const sessionsShareCopy = 'Copy share link';
  static const sessionsChild = 'child';
  static const sessionsDeleteTitle = 'Delete this session?';

  static String sessionsDeleteBody(String label) =>
      '"$label" and its entire history are permanently deleted.';

  // ---- history / sessions ----
  static const String historySearchHint = 'Search conversations';
  static const String historyToday = 'Today';
  static const String historyYesterday = 'Yesterday';
  static const String historyEarlier = 'Earlier';
  static const String historyNoResults = 'No conversations found';
  static const String historyNoResultsBody =
      'Nothing matches that search. Try a different word.';
  static const String historyDeleted = 'Conversation deleted';
  static const String historyUndo = 'Undo';
  static const String historyPin = 'Pin';
  static const String historyUnpin = 'Unpin';
  static const String historyPinned = 'Pinned';
  static const String historyFilterTip =
      'Main shows top-level chats. All sessions includes sub-sessions.';
  static const String clear = 'Clear';
  static String historyFiles(int n) => n == 1 ? '1 file' : '$n files';

  // ---- composer ----
  static const String badgeFree = 'Free';

  // ---- de-Hinglish sweep: copy that was inline in widgets ----
  // commands
  static const String cmdNoCommands = 'No commands';
  static String cmdArgs(String name) => '/$name arguments';
  static String cmdUseSkill(String name) => 'Use the $name skill to do this: ';
  static String cmdUseLabel(String name) => 'Use $name';
  static String partsAgent(String a) => 'Agent \u00b7 ${a.isEmpty ? '?' : a}';

  // diff
  static const String diffNoActiveSession = 'No active session.';
  static const String diffNotARepo =
      'This project is not a git repository, so there is no git diff.';
  static const String diffNoFilesBody =
      'No file has been modified in this session yet.';
  static const String diffNotTextual = 'This file has no textual diff.';
  static const String diffLoadFailed = 'Could not load the diff';
  static const String diffNoChanges = 'No changes';
  static const String diffNoChangesBody =
      'No tracked file has changed in this session.';
  static const String diffApplyTitle = 'Apply this patch?';
  static const String diffApplied = 'Applied';
  static const String diffNoneTitle = 'No diff';
  static const String diffCleanBody = 'The worktree is clean.';
  static String diffAppliesTo(String file) =>
      'This patch will be applied to $file.';

  // models
  static const String modelsLoadingProviders = 'Loading providers\\u2026';
  static const String modelsNoneTitle = 'No models found';
  static const String modelsNoneBody =
      'No provider is connected. Add an API key in Settings.';

  // prompts (permissions / questions)
  static const String permAllow = 'Allow';
  static const String permAlways = 'Always';
  static const String permDeny = 'Deny';
  static const String permSend = 'Send';

  // files
  static const String filesDeleteTitle = 'Delete?';
  static String filesDeleteBody(String p) => '$p will be deleted permanently.';
  static const String filesUnsaved = 'Unsaved changes';
  static const String filesSaveFailed = 'Could not save the file';
  static const String filesDeleteConfirm = 'Delete';
  static String filesNameLabel(bool folder) =>
      folder ? 'Folder name' : 'File name';
  static String filesEmptyName(bool folder) =>
      folder ? 'Folder name cannot be empty' : 'File name cannot be empty';
  static String filesNameHint(bool folder) =>
      folder ? 'new-folder' : 'untitled.md';
  static const String filesBinary = 'Binary file';
  static const String filesNoChanges = 'No tracked file has changed.';
  static const String filesNewTitle = 'New file or folder';
  static const String filesReadFailed = 'Could not read the file';
  static const String filesUnsavedExit =
      'You have unsaved changes. Discard them and exit?';
  static const String filesBadName =
      'Invalid name \u2014 "/" and ".." are not allowed';
  static const String filesEmptyHere = 'There are no files here.';
  static const String filesNotText = 'Not a text file, so it cannot be edited.';

  // settings
  static const String setAdd = 'Add';
  static const String setChangeServer = 'Change server';
  static const String setConnect = 'Connect';
  static String setPermExternalTitle(String path) =>
      'Allow external directory access?';
  static String setPermExternalBody(String path) =>
      'Grant write permission for $path.';
  static const String setInstanceRestart = 'Restart instance';
  static const String setInstanceRestartTitle = 'Restart the instance?';
  static String setPassword(String env) => 'Password ($env)';
  static const String setRevertLast = 'Revert the last message';
  static const String setRevertLastBody =
      'Undo the changes from the last message';
  static const String setRevertAllBodyShort = 'Undo every reverted change';
  static const String setExternalFolder = 'Grant external folder write access';
  static const String setExternalFolderSub =
      'Also create files outside the project folder';
  static const String setPermExternalNote =
      'This lets opencode write files outside the project folder '
      '(for example /storage/emulated/0/).';
  static String filesExists(String name) => '$name already exists';
  static String filesDeleteFailed(String p) => 'Could not delete $p';
  static String filesFolderFailed(String p) => 'Could not create $p';
  static const String shareLinkCreated = 'Share link created';
  static const String configSaved = 'Config saved';
  static String added(String name) => '$name added';

  // ---- third de-Hinglish sweep: toasts / empty states ----
  static const String codeCopied = 'Code copied';
  static const String contextCompacted = 'Context compacted';
  static const String questionMultiHint = 'More than one may be selected';
  static const String linkCopied = 'Link copied';
  static const String noMessagesYet = 'No messages yet';
  static const String instanceRestarted = 'Instance restarted';
  static const String externalPermGranted = 'External directory access granted';
  static const String noMcpServers = 'No MCP servers.';
  static const String noLspActive = 'No LSP is active.';
  static const String noFormatters = 'No formatter is configured.';
  static const String shellNoOutput2 = 'The shell produced no output.';

  static const String noProviderConnected =
      'No provider is connected. Add an API key below.';
  static const String patchConfigNote =
      'PATCH /config updates the global opencode config.';

  static const String externalPermEnabled = 'External directory access enabled';

  static const String nameLabel = 'Name';
  static String netTimeout(int s) => 'The server did not reply within ${s}s';
  static String netUnreachable(String root) =>
      'Could not reach the server.\n\nIs ${root} reachable?\n'
      'Is it running in Termux?';
  static const String shellNoOutput =
      'The shell produced no output \u2014 the command may not have run.';
  static const String permWhatDoing = 'opencode is about to:';
  static String permSuggestingRules(List<String> r) =>
      'The server suggests these rules: ${r.join(', ')}';
  static const String skipQ = 'Skip';

  // ---- second de-Hinglish sweep ----
  static const String filesNewFileItem = 'New file';
  static const String filesNewFolderItem = 'New folder';
  static const String filesPathHint = 'Path (relative to the project root)';
  static const String filesGo = 'Go';
  static const String filesRootCrumb = 'root';
  static String filesChangedCount(int n) => n == 1 ? '1 changed' : '$n changed';
  static const String filesDuplicate = 'Duplicate';
  static const String filesFolderExists = 'A folder with that name exists here';
  static const String filesChangedTitle = 'Changed files';
  static const String filesAllClean = 'All clean';
  static const String diffRefresh = 'Refresh';
  static const String diffApply = 'Apply';
  static const String partsPatch = 'Patch';
  static const String partsExternalAccess = 'Allow external access';
  static const String setUnrevert = 'Unrevert';
  static const String setUpgradeBody =
      'Dispose the current instance and start a fresh one';
  static const String setUpgradeSub =
      'Move server-side opencode to the latest version';
  static const String setUpgradeTitle = 'Upgrade?';
  static const String setUpgradeBody2 = 'The server may restart.';
  static const String setServerLabel = 'Server';
  static const String setUrlLabel = 'URL';
  static const String setUserLabel = 'Username (basic auth)';
  static const String modelsTitle = 'Models & Agents';
  static const String modelsFilterAll = 'All';
  static const String modelsNoneFiltered =
      'No model matches that filter. Try another one.';
  static const String modelsAgentLabel = 'Agent';
  static const String modelsReasoning = 'Reasoning';
  static const String modelsTools = 'Tools';
  static String modelsContext(int k) => '${k}k context';
  static String modelsSelected(String name) => 'Model: $name';
  static const String setUpgradeCmd = 'opencode upgrade';
  static const String setUpgradeConfirmBody =
      'The current instance will be disposed and any active work may stop.';
  static const String setMcpCommandLabel = 'Command (e.g. npx)';
  static String setMcpLabel(String type) =>
      type == 'local' ? setMcpCommandLabel : setUrlLabel;
  static const String setRevertAll = 'Revert all changes';
  static const String setRevertAllConfirm = 'Revert all?';
  static const String setRevertAllBody =
      'This reverts every change made in this project.';
  static const String setReconnect = 'Reconnect';

  // terminal
  static const String termClearTooltip = 'Clear output';
  static const String termWrap = 'Wrap';
  static const String termPrompt = 'command';
  static const String termEmptyTitle = 'Terminal';
  static const String termEmptyBody =
      'Run a shell command in the project directory.';

  static const String partsOutput = 'Output';
  static const String moreActions = 'More actions';
  static const String messageDeleted = 'Message deleted';
  static const String partsThinking = 'Thinking';
  static String partsThoughtFor(int secs) =>
      secs < 1 ? 'Thought for a moment' : 'Thought for ${secs}s';
  static String partsThinkingLines(int n) => n == 1 ? '1 line' : '$n lines';
  static const String composerPlaceholderStart = 'Ask anything\u2026';
  static const String composerPlaceholderReply = 'Reply to the agent\u2026';
  static const String composerStopHint = 'Tap to stop';
  static const String composerWorkingSlow = 'Taking longer than usual';
  static String composerWorking(String agent) =>
      agent.isEmpty ? 'Working\u2026' : '$agent is working\u2026';
  static String composerQueued(int n) =>
      n == 1 ? '1 message queued' : '$n messages queued';

  static String sessionsCount(int n) => '$n sessions';
  static String sessionsCountOne(int n) => '$n session';
  static String forkCreated(String label) => 'Forked: $label';

  // ------------------------------------------------------------------
  // files
  // ------------------------------------------------------------------
  static const filesTitle = 'Files';
  static const filesPathLabel = 'Path';
  static const filesPathOpen = 'Enter a path';
  static const filesFilterTooltip = 'Filters';
  static const filesShowIgnored = 'Show ignored files';
  static const filesChanged = 'Changed files';
  static const filesEmptyTitle = 'Empty folder';
  static const filesEmptyBody = 'There is no file here.';
  static const filesLoadFailed = 'Could not load this folder';
  static const filesSaved = 'Saved';
  static const filesRenameTitle = 'Rename';
  static const filesNewFolder = 'New folder here';
  static const filesNewFolderTitle = 'Folder name';
  static const filesSendToChat = 'Send to chat';
  static const filesProjectRoot = 'root';
  static const filesEditorTitle = 'Editor';
  static const filesUntitled = 'Untitled';
  static const filesBinaryTitle = 'Binary file';
  static const filesBinaryBody =
      'This is not a text file, so it cannot be edited.';
  static const filesEdited = 'edited';
  static const filesUnsavedTitle = 'Unsaved changes';
  static const filesUnsavedBody = 'You have unsaved changes. Exit anyway?';
  static const filesAllCleanTitle = 'Everything is clean';
  static const filesAllCleanBody = 'No tracked file has changes.';
  static const filesSendReview = 'Review this file: @%s';

  static String fileStats(int lines, int chars) =>
      '$lines lines · $chars chars';

  // ------------------------------------------------------------------
  // diff
  // ------------------------------------------------------------------
  static const diffTitle = 'Diff';
  static const diffSourceSession = 'Session';
  static const diffSourceGit = 'Git';
  static const diffWorktree = 'Worktree';
  static const diffStaged = 'Staged';
  static const diffNoSession = 'No active session';
  static const diffNoSessionBody = 'Open a session to see its changes.';
  static const diffClean = 'The worktree is clean';
  static const diffNoTextDiff = 'There is no textual diff for this file.';
  static const diffCopy = 'Copy diff';
  static const diffTruncated = '… %d more lines';

  static String diffAddedRemoved(int add, int del) => '+$add  −$del';

  // ------------------------------------------------------------------
  // tasks
  // ------------------------------------------------------------------
  static const tasksTitle = 'Tasks';
  static const tasksEmptyTitle = 'No tasks yet';
  static const tasksEmptyBodyNoSession = 'Start a chat first.';
  static const tasksEmptyBody =
      'Tasks appear here as soon as the agent writes its todo list.';
  static const tasksInProgress = 'In progress';
  static const tasksPending = 'Pending';
  static const tasksCompleted = 'Completed';
  static const tasksActive = 'active';
  static const tasksDoneLabel = 'done';

  static String tasksProgress(int done, int total) => '$done / $total done';
  static String tasksProgressSemantics(int done, int total) =>
      '$done of $total tasks done';

  // ------------------------------------------------------------------
  // terminal
  // ------------------------------------------------------------------
  static const terminalTitle = 'Terminal';
  static const terminalPlaceholder = 'Run a shell command';
  static const terminalRun = 'Run';
  static const terminalClear = 'Clear output';
  static const terminalInputLabel = 'Shell command';
  static const terminalPresetFiles = 'List files';
  static const terminalPresetDisk = 'Disk usage';
  static const terminalPresetGitStatus = 'git status';
  static const terminalPresetGitLog = 'git log';
  static const terminalPresetOpencodeVersion = 'opencode --version';

  // ------------------------------------------------------------------
  // commands
  // ------------------------------------------------------------------
  static const commandsTitle = 'Commands';
  static const commandsEmptyTitle = 'No commands';
  static const commandsEmptyBody =
      'Add markdown command files in .opencode/command/ or '
      '~/.config/opencode/command/ inside the project.';
  static const commandsSkills = 'Skills';
  static const commandsCount = '%d commands';
  static const commandsSkillsCount = 'Skills (%d)';
  static const commandsRun = 'Run /%s';
  static const commandsArgs = 'Arguments for /%s';
  static const commandsDescriptionMissing = 'No description';

  static String useSkillPrompt(String name) =>
      'Use the "$name" skill for this task.';

  // ------------------------------------------------------------------
  // models
  // ------------------------------------------------------------------
  static const modelsSearchHint = 'Search models';
  static const modelsLoading = 'Loading providers';
  static const modelsEmptyTitle = 'No model found';
  static const modelsEmptyBody = 'Connect a provider and add an API key.';
  static const modelsNoProvidersTitle = 'No provider connected';
  static const modelsNoProvidersBody = 'Add an API key in Settings.';
  static const modelsNoProvidersAction = 'Add an API key';
  static const modelsAgent = 'Agent';
  static const modelsProviderCount = '%d models';
  static const modelsProviderConnected = '%s connected';
  static const modelsApiKey = '%s API key';
  static const modelsKeyNever = 'not set';
  static const modelsKeySaved = 'saved';
  static const modelsKeyLabel = 'API key for %s';
  static const modelsUse = 'Use %s';

  // ------------------------------------------------------------------
  // settings
  // ------------------------------------------------------------------
  static const settingsTitle = 'Settings';
  static const settingsServer = 'Server';
  static const settingsUrl = 'URL';
  static const settingsUrlHint = 'http://127.0.0.1:4096';
  static const settingsUrlHelp = 'Use http://10.0.2.2:4096 from an emulator.';
  static const settingsUsername = 'Username (basic auth)';
  static const settingsPassword = 'Password (OPENCODE_SERVER_PASSWORD)';
  static const settingsChangeServer = 'Change server';
  static const settingsStatus = 'Status';
  static const settingsConnected = 'connected';
  static const settingsDisconnected = 'disconnected';
  static const settingsProject = 'Project';
  static const settingsWorktree = 'Worktree';
  static const settingsConfigDir = 'Config directory';
  static const settingsNotARepo = 'not a repository';
  static const notARepoShort = 'Not a repository';
  static const settingsChangeServerTitle = 'Change server';
  static const settingsChangeServerBody =
      'Save the endpoint and credentials, then reconnect.';
  static const settingsProviders = 'Providers';
  static const settingsProvidersEmpty = 'No provider connected';
  static const settingsProvidersEmptyBody =
      'Add an API key below to connect a provider.';
  static const settingsKeyPlaceholder = 'Paste the provider API key';
  static const settingsConfig = 'Config';
  static const settingsConfigSave = 'Save config';
  static const toolsTitle = 'Tools';
  static const toolsNone = 'No tools reported';
  static const toolsNoneBody = 'The server did not report any tools.';
  static const toolsEnableAll = 'Enable all';
  static const lspTitle = 'Language servers';
  static const lspNone = 'No language server active';
  static const formattersTitle = 'Formatters';
  static const formattersNone = 'No formatter';
  static const formattersNoneBody = 'No formatter is configured.';
  static const mcpTitle = 'MCP servers';
  static const mcpNone = 'No MCP server';
  static const mcpNoneBody = 'No MCP server is configured.';
  static const mcpAdd = 'Add MCP server';
  static const mcpName = 'Name';
  static const mcpNameHint = 'e.g. filesystem';
  static const mcpType = 'Type';
  static const mcpLocal = 'Local';
  static const mcpRemote = 'Remote';
  static const mcpUrl = 'URL';
  static const mcpCommand = 'Command';
  static const mcpCommandHint = 'e.g. npx';
  static const mcpArgs = 'Arguments';
  static const mcpArgsHint = 'One argument per line';
  static const mcpConfigNote =
      'PATCH /config updates the global opencode config on the server.';
  static const configInvalidJson = 'Invalid JSON: %s';
  static const configRootMustBeObject = 'The root value must be an object';
  static const externalDirectoryTitle =
      'Allow writing outside the project folder?';
  static const externalDirectoryBody =
      'This lets opencode write outside the project folder, for example '
      '/storage/emulated/0/.';
  static const externalDirectoryAction = 'Allow external folder';
  static const externalDirectoryDone = 'External folder access allowed';
  static const upgradeTitle = 'Upgrade opencode';
  static const currentSession = 'Current session';

  static String mcpCount(int n) => 'MCP servers ($n)';
  static String skillsCount(int n) => 'Skills ($n)';
  static String toolsCount(int n) => 'Tools ($n)';
  static String settingsConnectedVersion(String v) =>
      v.isEmpty ? settingsConnected : '$settingsConnected ($v)';

  // ------------------------------------------------------------------
  // prompts / permissions / questions
  // ------------------------------------------------------------------
  static const permissionTitle = 'Permission needed';
  static const permissionPending = '%d more request(s) pending';
  static const permissionOnce = 'Once';
  static const permissionDefault = 'Default';
  static const questionTitle = 'The agent asked a question';
  static const yourAnswer = 'Type your answer…';
  static const questionSubmit = 'Send';
  static const questionSelect = 'Choose an option';
  static const questionRequired = 'An answer is required';
  static const shareTitle = 'Share link ready';
  static const shareCopy = 'Copy link';
  static const shareCopied = 'Link copied';
  static const shareOpen = 'Open in browser';
  static const shareClose = 'Close';

  // ------------------------------------------------------------------
  // markdown / parts
  // ------------------------------------------------------------------
  static const partStep = 'Step';
  static const partReasoning = 'Reasoning';
  static const partTool = 'Tool';
  static const partFile = 'File';
  static const partSnapshot = 'Snapshot';
  static const partCompaction = 'Compaction';
  static const partSubtask = 'Subtask';
  static const partUnknown = 'Unknown';
  static const partRaw = 'Raw output';
  static const partRetry = 'Retry';
  static const partOpenFile = 'Open file';
  static const partShowRaw = 'Show raw output';
  static const partHideRaw = 'Hide raw output';
  static const partUnknownBody =
      'The server sent a part type this app does not know yet.';
  static const partFileChanged = '%s changed on disk';
  static const partReadMore = 'Read more';
  static const partReadLess = 'Read less';
  static const markdownCopyCode = 'Copy code';
  static const markdownCodeCopied = 'Code copied';
  static const markdownTruncated = '… %d more chars (%d lines)';
  static const markdownLinkOpenError = 'Could not open the link';

  // ------------------------------------------------------------------
  // model pickers inside the composer
  // ------------------------------------------------------------------
  static const pickerAgentTitle = 'Agent';
  static const pickerToolsTitle = 'Tools';
  static const pickerCommandsTitle = 'Commands';
  static const pickerFilesTitle = 'Project files';

  // extra session/parts/settings copy
  static const settingsInitAgents = 'Create AGENTS.md (/init)';
  static const settingsInitAgentsHint = 'Generate the project instruction file';
  static const settingsSummarize = 'Summarize';
  static const settingsSummarizeHint = 'Compact the context of this chat';
  static const settingsRevert = 'Revert';
  static const settingsRevertHint = 'Undo the changes of the last message';
  static const settingsUnrevert = 'Unrevert';
  static const settingsUnrevertHint = 'Restore every reverted change';
  static const settingsNoMessages = 'There is no message yet';
  static const settingsUpgrade = 'Update opencode';
  static const settingsUpgradeHint = 'Update opencode on the server side';
  static const settingsLogout = 'Log out';
  static const modelsOnlyConnected = 'Only connected providers';
  static const modelsChangeFilter = 'Try a different filter.';
  static const commandsArgsHint = 'Type the arguments';
  static const diffBinaryBadge = 'binary or new file';
  static const questionSend = 'Send';
  static const partCompacted = 'Context compacted';
  static const partPatch = 'Patch';
  static const partRevertHint = 'Undo the changes of this message';
  static const partUnrevertHint = 'Restore every reverted change';
  static const partReadToolHint = 'The file content is inlined below';

  // ==================================================================
  // Dark redesign. Grouped by the fix that introduced them.
  // ==================================================================

  // --- fix 0/2: connection status ------------------------------------
  /// Shown once, in the header.
  static const statusConnected = 'Connected';
  static const statusReconnecting = 'Reconnecting';
  static const statusOffline = 'Offline';
  static const statusRetry = 'Retry';
  static const statusRetryTooltip = 'Retry the connection';

  /// Honest about cached data: the list below is real, the server is not.
  static const statusOfflineCached = 'Offline — showing cached';

  static String statusCached(int n) => 'Offline — showing $n cached';

  // --- fix 2: contextual header actions -----------------------------
  static const headerSearch = 'Search';
  static const headerSearchTooltip = 'Search chats';
  static const headerRefresh = 'Refresh';
  static const headerRefreshTooltip = 'Reload from the server';
  static const headerClear = 'Clear';
  static const headerClearTooltip = 'Clear the terminal output';
  static const headerNewSession = 'New session';
  static const headerNewSessionTooltip = 'Start a new terminal session';
  static const headerNewFile = 'New file';
  static const headerNewFolder = 'New folder';
  static const headerNewTooltip = 'Create a file or a folder';
  static const headerTasksTooltip = 'Open the task list';

  // --- fix 3: hero chips ---------------------------------------------
  static const chipFree = 'Free';
  static const chipFreeTooltip = 'This model is free to use';

  // --- fix 5: composer -----------------------------------------------
  static const composerPlaceholder =
      'Ask the agent to build, fix, or explain...';
  static const composerQueuedTooltip = 'This message is queued';
  static const composerSendTooltip = 'Send';
  static const composerStopTooltip = 'Stop the current turn';
  static const composerMicTooltip = 'Voice input';
  static const composerMicBody = 'Voice input is not available yet.';

  // --- fix 6: options sheet ------------------------------------------
  static const sheetGroupSession = 'Session';
  static const sheetGroupAgent = 'Agent';
  static const sheetGroupApp = 'App';
  static const sheetRename = 'Rename';
  static const sheetDiff = 'Diff';
  static const sheetHistory = 'History';
  static const sheetTools = 'Tools';
  static const sheetCommands = 'Commands';
  static const sheetSettingsUsage = 'Settings & token usage';
  static const sheetAbout = 'About';

  // --- fix 4: running chat --------------------------------------------
  static const thinkingCollapsedTooltip = 'Show what the agent was thinking';
  static String thinkingGroup(int seconds, int steps) => seconds >= 60
      ? 'Thought for ${seconds ~/ 60}m ${seconds % 60}s · $steps steps'
      : 'Thought for ${seconds}s · $steps steps';
  static String thinkingSteps(int n) => n == 1 ? '1 step' : '$n steps';
  static const working = 'Working...';
  static String jumpUnread(int n) =>
      n == 1 ? '1 new message' : '$n new messages';
  static const messageRetry = 'Retry';
  static const messageRetryTooltip = 'Run this turn again';
  static const messageUndoConfirmTitle = 'Undo this message?';
  static const messageUndoConfirmBody =
      'The agent reply that follows it is removed too. This cannot be undone.';
  static const messageUndoConfirmAction = 'Undo';
  static const messageUndoDone = 'Message undone';
  static const messageUndoAgain = 'Undo undo';
  static const retryDone = 'Running again';
  static const partOutputCopy = 'Copy output';
  static const partCommandCopy = 'Copy command';
  static const partExpand = 'Expand';
  static const partCollapse = 'Collapse';

  // --- fix 7: history ------------------------------------------------
  static const historySegmentPrimary = 'Primary';
  static const historySegmentAll = 'All sessions';
  static const historySegmentTooltip =
      'Primary shows top-level chats; All sessions includes sub-sessions';
  static const historyUntitled = 'Untitled';
  static const historyEmptyTitle = 'No chats yet';
  static const historyEmptyBody = 'Start a chat and it will show up here.';
  static const historyEmptySearch = 'No chats match that search';
  static const historyRename = 'Rename';
  static const historyDelete = 'Delete';
  static const historyDeleteTitle = 'Delete this session?';
  static String historyDeleteBody(String title) =>
      '"$title" and its messages will be removed from the server.';

  // --- fix 8: files ---------------------------------------------------
  static const filesShowIgnoredTooltip =
      'Includes .git, node_modules, build output and anything in .gitignore';
  static const filesClearPath = 'Clear path';
  static const filesNew = 'New';
  static const filesRoot = 'root';
  static const filesCopyPath = 'Copy path';
  static const filesErrorTitle = 'Could not read this folder';
  static const filesLoading = 'Reading the folder';
  static String filesItems(int n) => n == 1 ? '1 item' : '$n items';
  static String filesSelected(int n) => n == 1 ? '1 selected' : '$n selected';
  static const deleteFile = 'Delete';

  // --- fix 9: models & agents -----------------------------------------
  static const modelsConnectedOnly = 'Connected providers only';
  static const modelsCapReasoning = 'Reasoning';
  static const modelsCapTools = 'Tools';
  static const modelsCapVision = 'Vision';
  static const modelsCapFiles = 'Files';
  static String modelsProvider(int n) => n == 1 ? '1 model' : '$n models';
  static const agentSelector = 'Agent';
  static String agentPrimary(String name) => '$name — primary';

  /// 262K / 1M / 128K. Anything under 1024 stays in K so a 1.2M-token window does
  /// not render as "1200.0K".
  static String formatContext(int tokens) {
    if (tokens >= 1000000) {
      final m = tokens / 1000000;
      return m >= 10 || m == m.roundToDouble()
          ? '${m.round()}M'
          : '${m.toStringAsFixed(1)}M';
    }
    if (tokens >= 1000) return '${(tokens / 1000).round()}K';
    return '$tokens';
  }

  // --- fix 10: terminal ------------------------------------------------
  static const termInputHint = 'Enter a command';
  static const termRun = 'Run';
  static const termSendTooltip = 'Run this command';
  static const termCopyOutput = 'Copy output';
  static const termHistoryPrev = 'Previous command';
  static const termHistoryNext = 'Next command';
  static const termQuickTooltip = 'Tap to insert · long-press to run';
  static const termCopyPath = 'Copy path';
  static const termChangeDir = 'Change directory';
  static const termCancel = 'Cancel';
  static const termFailed = 'Command failed';

  // --- fix 9: about ----------------------------------------------------
  static const aboutStatusTitle = 'Server';
  static const aboutVersionLabel = 'Version';

  // --- misc -------------------------------------------------------------
  static const todosEmptyTitle = 'No tasks yet';
  static const todosEmptyNoChat = 'Start a chat first.';
  static const todosEmptyHint =
      'Tasks appear here as soon as the agent uses the todo tool.';
  static const questionCustomHint = 'Type your answer';
  static const cmdArgsHint = 'Type the arguments';
  static const setInitAgents = 'Create AGENTS.md (/init)';
  static const setInitAgentsSub = "Generate the project's instruction file";
  static const setSummarize = 'Summarize';
  static const setSummarizeSub = 'Compact the context of this chat';
  static const setAddMcp = 'Add MCP server';
  static const setSaveConfig = 'Save config';

  static const pickModelFirst = 'Pick a model first';
  static const sendMessageFirst = 'Send a message first';
  static const errNoActivity =
      'No activity from the server for 5 minutes. Check the server logs or retry.';
  static String termuxSetupNote(String command) =>
      'opencode server must be running in Termux, started from the project folder '
      'you want to see. Command: $command';

  // ------------------------------------------------------------------
  // helpers
  // ------------------------------------------------------------------
  static String label(String l, String value) => '$l: $value';
  static String slashCommand(String name) => '/$name';
  static String errorText(Object e) => '$e';
}
