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
  static const navSessions = 'Sessions';
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
  static const chatWelcomeSubtitle = '%s · agent %s';
  static const chatWelcomeEmptySubtitle = 'Pick a model to get started';
  static const chatLoadOlderFailed = 'Could not load older messages';

  static const chatSuggestionStructure =
      'Explain this project structure briefly';
  static const chatSuggestionTests = 'Run the tests and explain failures';
  static const chatSuggestionTodo = 'Find the biggest TODO in the repo';
  static const chatSuggestionPlan = 'Draft a plan for a new feature';

  static const chipModel = 'Model';
  static const chipPickModel = 'Pick a model';
  static const chipAgent = 'Agent';
  static const chipTools = 'Tools';
  static const chipToolsAll = 'All tools enabled';
  static const chipHideRow = 'Hide options';
  static const chipShowRow = 'Show options';

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

  static String sessionsCount(int n) => '$n sessions';
  static String sessionsCountOne(int n) => '$n session';
  static String forkCreated(String label) => 'Forked: $label';

  // ------------------------------------------------------------------
  // files
  // ------------------------------------------------------------------
  static const filesTitle = 'Files';
  static const filesPathLabel = 'Path';
  static const filesPathHint = 'Relative to the project root';
  static const filesPathOpen = 'Enter a path';
  static const filesFilterTooltip = 'Filters';
  static const filesShowIgnored = 'Show ignored files';
  static const filesChanged = 'Changed files';
  static const filesChangedCount = '%d changed';
  static const filesEmptyTitle = 'Empty folder';
  static const filesEmptyBody = 'There is no file here.';
  static const filesLoadFailed = 'Could not load this folder';
  static const filesSaved = 'Saved';
  static const filesRenameTitle = 'Rename';
  static const filesDuplicate = 'Duplicate';
  static const filesNewFolder = 'New folder here';
  static const filesNewFolderTitle = 'Folder name';
  static const filesSendToChat = 'Send to chat';
  static const filesDeleteTitle = 'Delete?';
  static const filesProjectRoot = 'root';
  static const filesEditorTitle = 'Editor';
  static const filesUntitled = 'Untitled';
  static const filesBinaryTitle = 'Binary file';
  static const filesBinaryBody =
      'This is not a text file, so it cannot be edited.';
  static const filesReadFailed = 'This file could not be read';
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
  static const diffLoadFailed = 'The diff could not be loaded';
  static const diffNoChanges = 'No changes';
  static const diffNoChangesBody =
      'This session has not modified any file yet.';
  static const diffNotARepo = 'This project is not a git repository';
  static const diffClean = 'The worktree is clean';
  static const diffNoTextDiff = 'There is no textual diff for this file.';
  static const diffCopy = 'Copy diff';
  static const diffApply = 'Apply patch';
  static const diffApplyTitle = 'Apply the patch?';
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
  static const modelsTitle = 'Models & Agents';
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

  // ------------------------------------------------------------------
  // helpers
  // ------------------------------------------------------------------
  static String label(String l, String value) => '$l: $value';
  static String slashCommand(String name) => '/$name';
  static String errorText(Object e) => '$e';
}
