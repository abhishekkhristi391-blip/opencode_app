# FILES - one card per file (read this instead of opening files blindly)
Format: Defines / Imports / Imported by / Calls into / If changed -> affected files / Issues / Notes

## deploy.py  (201 lines)
- Defines (read with exact line ranges): function run L38-52, function fail L53-57, function norm L58-66, function allowed L67-76, function staged_files L77-82, function check_paths L83-104, function main L105-201

## lib/api/client.dart  (24 lines)
- Imports: lib/l10n/strings.dart, lib/models/models.dart
- Imported by (8): lib/state/store.dart, lib/ui/chat.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart
- If changed, affects 19 file(s): lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart ...

## lib/api/client/client_oc_client.dart  (44 lines)
- Defines (read with exact line ranges): class ApiException L3+, function toString L13-16, function _parseBytes L17-25, class OcClient L26+

## lib/api/client/client_oc_client_http.dart  (210 lines)
- Defines (read with exact line ranges): class OcClientHttp L8+, function _headers L13-20, function _u L21-34, function _decode L35-77, function _sendOnce L78-125, function _send L126-141, function get L142-151, function post L152-165, function patch L166-179, function put L180-193, function delete L194-207, function close L208-210

## lib/api/client/client_oc_client_messages.dart  (169 lines)
- Defines (read with exact line ranges): class OcClientMessages L8+, function replyPermission L9-19, function replyPermissionV1 L20-53, function message L54-58, function deleteMessage L59-64, function promptAsync L65-169

## lib/api/client/client_oc_client_server.dart  (93 lines)
- Defines (read with exact line ranges): class OcClientServer L8+, function paths L16-18, function vcs L19-20, function disposeInstance L21-23, function upgrade L24-27, function log L28-37, function config L38-39, function patchConfig L40-42, function configProviders L43-51, function providers L52-54, function providerAuthMethods L55-65, function providerAuthUrl L66-77, function setApiKey L78-85, function removeAuth L86-89, function agents L90-93

## lib/api/client/client_oc_client_sessions.dart  (130 lines)
- Defines (read with exact line ranges): class OcClientSessions L8+, function sessions L11-15, function createSession L16-34, function session L35-37, function deleteSession L38-40, function renameSession L41-45, function childSessions L46-50, function sessionStatus L51-53, function todos L54-58, function abort L59-62, function fork L63-67, function share L68-73, function unshare L74-79, function diff L80-84, function init L85-101, function summarize L102-113, function revert L114-126, function unrevert L127-130

## lib/api/client/client_oc_client_workspace.dart  (150 lines)
- Defines (read with exact line ranges): class OcClientWorkspace L8+, function commands L11-15, function skills L16-20, function toolIds L21-27, function files L28-32, function readFile L33-37, function fileStatus L38-42, function findFiles L43-54, function grep L55-63, function symbols L64-70, function vcsDiffRaw L71-73, function vcsDiff L74-79, function vcsStatus L80-85, function vcsApply L86-95, function mcp L96-100, function mcpAdd L101-108, function mcpConnect L109-112, function mcpDisconnect L113-116, function lsp L117-121, function formatters L122-128, function pendingQuestions L129-131, function pendingPermissions L132-134, function answerQuestion L135-141, function rejectQuestion L142-146, function tui L147-150

## lib/api/client/client_provider_types.dart  (90 lines)
- Defines (read with exact line ranges): class ProviderInfo L3+, class ProviderEntry L41+, class AuthMethod L72+

## lib/api/events.dart  (429 lines)
- Defines (read with exact line ranges): class OcEvent L12+, class EventStream L48+, function start L129-135, function reconnect L136-147, function _connect L148-248, function _checkLiveness L249-260, function _probeLiveness L261-325, function _handleFrame L326-342, function _setConnected L343-352, function _markDown L353-361, function _scheduleRetry L362-388, function stop L389-400, function shutdown L401-409, function _teardown L410-429
- Imports: lib/models/models.dart
- Imported by (1): lib/state/store.dart
- If changed, affects 19 file(s): lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart ...

## lib/db/chat_db.dart  (235 lines)
- Defines (read with exact line ranges): class ChatDB L21+, function _init L42-64, function _createMessages L65-79, function _createSessions L80-93, function _enqueue L94-106, function _sortKey L107-117, function _writeRow L118-131, function upsertMessages L132-150, function deleteMessage L151-162, function loadMessages L163-183, function clearSession L184-193, function saveSessions L194-211, function saveSession L212-216, function deleteSessionRow L217-224, function loadSessions L225-235
- Imported by (1): lib/state/store.dart
- If changed, affects 19 file(s): lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart ...

## lib/l10n/strings.dart  (1155 lines)
- Defines (read with exact line ranges): class S L9+, function serverOnlineVersion L111-190, function composerModelAgent L191-196, function toolRunning L197-197, function toolDone L198-204, function moreToolsCount L205-250, function filesCount L251-251, function messageCount L252-252, function tokensUsed L253-280, function sessionsDeleteBody L281-299, function historyFiles L300-307, function cmdArgs L308-308, function cmdUseSkill L309-309, function cmdUseLabel L310-310, function partsAgent L311-327, function diffAppliesTo L328-360, function filesDeleteBody L361-364, function filesNameLabel L365-366, function filesEmptyName L367-368, function filesNameHint L369-385, function setPermExternalTitle L386-387, function setPermExternalBody L388-391, function setPassword L392-402, function filesExists L403-403, function filesDeleteFailed L404-404, function filesFolderFailed L405-407, function added L408-430, function netTimeout L431-431, function netUnreachable L432-437, function permSuggestingRules L438-447, function filesChangedCount L448-473, function modelsContext L474-474, function modelsSelected L475-479, function setMcpLabel L480-499, function partsThoughtFor L500-501, function partsThinkingLines L502-508, function waitingYou L509-513, function promptSemantics L514-515, function composerWorking L516-517, function composerQueued L518-520 ...
- Imported by (17): lib/api/client.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...
- If changed, affects 21 file(s): lib/api/client.dart, lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart ...

## lib/main.dart  (111 lines)
- Defines (read with exact line ranges): function main L13-17, class OpenCodeApp L18+, function createState L22-24, class _OpenCodeAppState L25+, function initState L34-44, function dispose L45-52, function didChangeAppLifecycleState L53-79, function build L80-111
- Imports: lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/home.dart, lib/ui/prompts.dart, lib/ui/theme.dart, lib/voice/voice_scope.dart, lib/voice/voice_service.dart

## lib/models/models.dart  (9 lines)
- Imported by (15): lib/api/client.dart, lib/api/events.dart, lib/state/store.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart ...
- If changed, affects 21 file(s): lib/api/client.dart, lib/api/events.dart, lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart ...

## lib/models/models/models_server_info.dart  (444 lines)
- Defines (read with exact line ranges): class ModelInfo L3+, class Todo L46+, class FileNode L75+, class FileDiff L97+, class CommandInfo L123+, class SkillInfo L144+, class NamedStatus L159+, class VcsInfo L182+, class ServerPaths L194+, class PermissionReq L215+, function _fmt L336-342, class QuestionOption L343+, class QuestionItem L350+, class QuestionReq L373+, function fmtBytes L403-408, function fmtTime L409-414, function fmtAge L415-424, function fmtDuration L425-432, function baseName L433-437, function dirName L438-444

## lib/models/models/models_session_message.dart  (401 lines)
- Defines (read with exact line ranges): function asMap L3-6, function asList L7-8, function asInt L9-12, function asStr L13-14, function asDouble L15-17, function asBool L18-21, class Tokens L22+, class SessionSummary L50+, class PendingPrompt L71+, class Session L94+, function toMap L153-157, class Message L158+, class ToolStatus L236+, class Part L238+, function _short L364-373, class Agent L374+
- WHY: the raw message needs this before the UI can show anything. :218

## lib/state/store.dart  (31 lines)
- Imports: lib/api/client.dart, lib/api/events.dart, lib/db/chat_db.dart, lib/l10n/strings.dart, lib/models/models.dart
- Imported by (17): lib/main.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart ...
- If changed, affects 18 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart ...

## lib/state/store/store_ocstore.dart  (301 lines)
- Defines (read with exact line ranges): class OcStore L5+, function _messageText L125-148, function _stripEchoedOptimistic L149-244, function _parentDir L245-250, function _shellQuote L251-285, function dispose L286-301

## lib/state/store/store_ocstore_cache.dart  (171 lines)
- Defines (read with exact line ranges): class OcStoreCache L9+, function _scheduleNotify L17-31, function _scheduleMessageNotify L32-50, function _debouncedTodos L51-65, function _dbRow L66-76, function _isCacheable L77-91, function _mergeHistory L92-112, function _cachedHistory L113-130, function _scheduleFlush L131-148, function _flushHistory L149-164, function _persistHistory L165-171

## lib/state/store/store_ocstore_connection.dart  (329 lines)
- Defines (read with exact line ranges): class OcStoreConnection L9+, function boot L19-34, function _persist L35-51, function setServer L52-59, function connect L60-109, function _offlineMessage L110-118, function _verifyReachability L119-173, function _startStream L174-195, function _onStreamStatus L196-227, function _resyncMessages L228-260, function refreshServerInfo L261-270, function refreshCatalog L271-302, function setModel L303-309, function setAgent L310-315, function toggleTool L316-329
- NOTE: there is deliberately no storage-permission gate here. File writes go :11
- TODO: updates that landed while the socket was down are gone with it, and :215

## lib/state/store/store_ocstore_events.dart  (270 lines)
- Defines (read with exact line ranges): class OcStoreEvents L9+, function handleEvent L14-30, function _repliedId L31-39, function _promptParseFailed L40-47, function _handleEvent L48-262, function _errorText L263-270

## lib/state/store/store_ocstore_history.dart  (230 lines)
- Defines (read with exact line ranges): class OcStoreHistory L9+, function _prependHistory L12-28, function _widenHistory L29-56, function loadOlderMessages L57-97, function addAttachment L98-102, function removeAttachment L103-107, function clearAttachments L108-112, function _partPayload L113-129, function sendOrQueue L130-144, function _flushQueue L145-156, function send L157-230

## lib/state/store/store_ocstore_messages.dart  (238 lines)
- Defines (read with exact line ranges): class OcStoreMessages L9+, function _isCurrent L12-14, function _messageById L15-22, function _optimisticIndex L23-30, function _clearLocalEcho L31-35, function _upsertMessage L36-62, function _upsertPart L63-125, function _applyDelta L126-142, function _removePart L143-160, function _removeMessage L161-176, function _upsertSession L177-192, function _toast L193-193, function takeToast L194-200, function reconnectStream L201-209, function pauseConnections L210-228, function resumeConnections L229-238

## lib/state/store/store_ocstore_prompts.dart  (154 lines)
- Defines (read with exact line ranges): class OcStorePrompts L9+, function loadPending L14-54, function resyncPrompts L55-82, function _resyncPromptsOnce L83-106, function answerPermission L107-127, function answerQuestion L128-140, function rejectQuestion L141-154

## lib/state/store/store_ocstore_run.dart  (262 lines)
- Defines (read with exact line ranges): class OcStoreRun L9+, function _touchActivity L10-14, function _startBusyTimer L15-46, function _probeBusyState L47-94, function _clearBusyTimer L95-107, function _settleStuckStreaming L108-118, function _sendParts L119-166, function runCommand L167-203, function summarize L204-213, function revert L214-224, function unrevert L225-235, function initAgents L236-262

## lib/state/store/store_ocstore_sessions.dart  (323 lines)
- Defines (read with exact line ranges): class OcStoreSessions L9+, function refreshSessions L14-40, function _persistSessions L41-51, function _restoreSessionsFromCache L52-70, function newSession L71-88, function openSession L89-147, function _safeSession L148-156, function renameSession L157-165, function deleteSession L166-183, function forkSession L184-194, function shareSession L195-204, function unshareSession L205-213, function abortSession L214-241, function refreshTodos L242-279, function _applyTodosPayload L280-304, function ensureTodosFresh L305-311, function refreshDiff L312-323

## lib/state/store/store_ocstore_view_state.dart  (118 lines)
- Defines (read with exact line ranges): class OcStoreViewState L9+, function setShowTokensInChat L15-57, function _stampArrival L58-64, function _forgetArrival L65-75, function openPromptSheet L76-85, function dismissPromptSheet L86-93, function _onPromptAdded L94-100, function _onPromptRemoved L101-108, function sessionLabel L109-118

## lib/state/store/store_ocstore_workspace.dart  (203 lines)
- Defines (read with exact line ranges): class OcStoreWorkspace L9+, function _utilSession L10-64, function writeFile L65-104, function deleteEntry L105-115, function mkdirEntry L116-130, function refreshCommands L131-140, function refreshConfig L141-152, function saveConfig L153-163, function enableExternalDirectoryAccess L164-179, function addMcp L180-203

## lib/state/store/store_types.dart  (75 lines)
- Defines (read with exact line ranges): class ChatMessage L3+, class PendingAttachment L35+, class MessageListSignal L57+, function notify L62-71, class TodoListSignal L72+

## lib/ui/about_page.dart  (120 lines)
- Defines (read with exact line ranges): class AboutPage L11+, function build L15-120
- Imports: lib/l10n/strings.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/app_scope.dart  (23 lines)
- Defines (read with exact line ranges): class AppScope L6+, function of L10-16, function read L17-23
- Imports: lib/state/store.dart
- Imported by (14): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart ...
- If changed, affects 14 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...

## lib/ui/chat.dart  (42 lines)
- Imports: lib/api/client.dart, lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/line_icons.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/primitives.dart, lib/ui/prompts.dart, lib/ui/theme.dart, lib/ui/widgets.dart, lib/voice/voice_scope.dart, lib/voice/voice_service.dart
- Imported by (5): lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart
- If changed, affects 6 file(s): lib/main.dart, lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/chat/chat_agent_sheets.dart  (267 lines)
- Defines (read with exact line ranges): class _ModelPill L16+, function build L21-33, function showAgentSheet L34-83, function showModelSheet L84-127, class _SheetOption L128+, function _pickAgentSheet L163-204, function _pickToolsSheet L205-267

## lib/ui/chat/chat_composer.dart  (395 lines)
- Defines (read with exact line ranges): class _ComposerWidget L27+, function build L39-55, class _Composer L56+, function _showAttachSheet L190-250, function _pickImage L251-270, function _pickProjectFile L271-295, function _mimeFor L296-310, function _showCommands L311-355, class _AttachmentStrip L356+

## lib/ui/chat/chat_file_picker.dart  (130 lines)
- Defines (read with exact line ranges): class _FilePickerSheet L3+, function createState L7-9, class _FilePickerSheetState L10+, function initState L17-21, function _load L22-48, function build L49-113, function _iconFor L114-130

## lib/ui/chat/chat_input_controls.dart  (218 lines)
- Defines (read with exact line ranges): class SlashTextField L4+, function createState L20-22, class _SlashTextFieldState L23+, function initState L31-40, function dispose L41-47, function _onChanged L48-73, function _debouncedSearchFiles L74-81, function _searchFiles L82-94, function _set L95-106, function _apply L107-128, function build L129-218

## lib/ui/chat/chat_message.dart  (342 lines)
- Defines (read with exact line ranges): class SuggestionCard L8+, function createState L21-23, class _SuggestionCardState L24+, function build L28-108, class _MessageTile L109+, class _MessageTileState L124+, function didChangeDependencies L137-141, function _signature L142-164, function _openMenu L165-168, function _buildContent L169-230, function _userBubble L231-288, function _assistantBlock L289-342

## lib/ui/chat/chat_message_actions.dart  (248 lines)
- Defines (read with exact line ranges): function showMessageMenu L8-101, class _SheetRow L102+, function build L115-138, class _IncomingFileChip L139+, class _MessageActions L175+, class _ActionDot L209+

## lib/ui/chat/chat_page.dart  (388 lines)
- Defines (read with exact line ranges): class ChatPage L3+, function createState L7-14, class _ChatPageState L15+, function initState L67-88, function dispose L89-107, function _insertUtterance L108-122, function _onStoreChange L123-135, function _chatMessageCount L136-146, function _onScroll L147-158, function _bumpUnread L159-166, function _handleNotification L167-189, function _setFollow L190-199, function _queueAutoScroll L200-213, function _runAutoScroll L214-224, function _jumpToLatest L225-243, function _loadOlderMessages L244-266, function _syncFollow L267-301, function build L302-340, function _sendSuggestion L341-349, function _send L350-388

## lib/ui/chat/chat_reply_meta.dart  (174 lines)
- Defines (read with exact line ranges): class _ReplyMeta L5+, function build L11-36, class _ReplyActions L37+, class _ReadAloudAction L89+, class _ActionBtn L127+

## lib/ui/chat/chat_run_progress.dart  (368 lines)
- Defines (read with exact line ranges): class _WorkingStrip L15+, function createState L21-23, class _WorkingStripState L24+, function initState L39-45, function _armSlowTimer L46-55, function dispose L56-61, function build L62-194, class _PromptChip L195+, class _QueuedStrip L235+, function isFreeModel L268-281, class _RunProgressLine L282+, class _IndeterminateBar L309+, class _IndeterminateBarState L317+, class _BarPainter L346+, function paint L352-365, function shouldRepaint L366-368
- WHY: * the agent is quiet. A pending :9

## lib/ui/chat/chat_send_button.dart  (170 lines)
- Defines (read with exact line ranges): class _SendButton L5+, function build L24-103, function _dictation L104-116, class _CircleButton L117+

## lib/ui/chat/chat_status.dart  (136 lines)
- Defines (read with exact line ranges): class _BusyBar L3+, function build L8-19, class _InlineError L20+, function _isCancellation L28-80, class _TypingDots L81+, function createState L85-87, class _TypingDotsState L88+, function dispose L96-136

## lib/ui/chat/chat_transcript.dart  (246 lines)
- Defines (read with exact line ranges): class _BusyBarWidget L4+, function build L8-25, class _ChatMessages L26+, function _buildList L59-152, class _JumpToLatest L153+, class _LoadOlderButton L221+

## lib/ui/chat/chat_voice_strip.dart  (297 lines)
- Defines (read with exact line ranges): function voiceFailureText L8-29, class _VoiceStrip L30+, function createState L34-36, class _VoiceStripState L37+, function _reportOnce L45-67, function build L68-138, class _LevelDot L139+, class _LevelDotState L149+, function dispose L157-198, class _HandsFreeButton L199+, function _button L213-256, function toggleHandsFree L257-276, class _HandsFreeSheetRow L277+
- WHY: hands-free or dictation stopped gets one snackbar, not a banner that :42

## lib/ui/chat/chat_welcome.dart  (345 lines)
- Defines (read with exact line ranges): class _Welcome L7+, function build L22-104, class _ModelModeChips L105+, class OutlinedChip L140+, class _ProjectBar L230+, function _showDetails L298-345

## lib/ui/commands_page.dart  (223 lines)
- Defines (read with exact line ranges): class CommandsPage L14+, function build L18-45, class _CommandTile L46+, class SkillsSection L151+
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/markdown.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (2): lib/ui/home.dart, lib/ui/settings_page.dart
- If changed, affects 3 file(s): lib/main.dart, lib/ui/home.dart, lib/ui/settings_page.dart

## lib/ui/diff_page.dart  (485 lines)
- Defines (read with exact line ranges): class DiffPage L13+, function createState L17-19, class _DiffPageState L20+, function initState L30-34, function _load L35-81, function build L82-206, class _SessionDiffTile L207+, function _unifiedPreview L341-356, function _split L357-360, function _diffOps L361-406, function _toGitPatch L407-409, class _GitDiffView L410+
- Imports: lib/api/client.dart, lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/parts.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/files_page.dart  (16 lines)
- Imports: lib/api/client.dart, lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/files_page/files_page_browser.dart  (460 lines)
- Defines (read with exact line ranges): class FilesPage L3+, function createState L7-9, class FilesPageState L10+, function initState L20-25, function reload L26-29, function promptCreate L30-32, function dispose L33-40, function _normDir L41-53, function _validName L54-64, function _createMenu L65-94, function _newFile L95-125, function _newFolder L126-141, function _load L142-179, function build L180-345, function _open L346-353, function _menu L354-457, function _q L458-460

## lib/ui/files_page/files_page_changed_editor.dart  (340 lines)
- Defines (read with exact line ranges): function _pillBorder L5-12, class ChangedFilesPage L13+, function build L17-62, class _FileTile L63+, function _icon L113-140, class FileEditorPage L141+, function createState L146-148, class _FileEditorPageState L149+, function initState L158-163, function dispose L164-170, function _load L171-194, function _save L195-340

## lib/ui/home.dart  (32 lines)
- Imports: lib/api/client.dart, lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/line_icons.dart, lib/ui/models_page.dart, lib/ui/primitives.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart
- Imported by (1): lib/main.dart
- If changed, affects 1 file(s): lib/main.dart

## lib/ui/home/home_avatar_drawer.dart  (411 lines)
- Defines (read with exact line ranges): class _AvatarButton L5+, function createState L15-17, class _AvatarButtonState L18+, function initState L28-34, function _startPulse L35-43, function didUpdateWidget L44-55, function dispose L56-62, function build L63-127, class _PromptCountBadge L128+, class _DrawerBadge L178+, class _Drawer L213+

## lib/ui/home/home_drawer_rows.dart  (367 lines)
- Defines (read with exact line ranges): class _DrawerNavRow L5+, function build L23-82, class _DrawerRecentRow L83+, class _DrawerFooter L170+, class _DrawerIconButton L320+

## lib/ui/home/home_server_menu.dart  (412 lines)
- Defines (read with exact line ranges): class _ServerMenu L8+, function build L34-121, class _ServerMenuHeader L122+, class _MenuRow L234+, class _SheetOption L329+, class _SheetGroup L390+

## lib/ui/home/home_shell.dart  (652 lines)
- Defines (read with exact line ranges): class _Tab L4+, class HomeShell L17+, function createState L21-23, class HomeShellState L24+, function goTo L47-50, function _navigate L51-55, function _pushAndClose L56-56, function Function L57-67, function _todosActions L68-76, function _worktree L77-82, function build L83-145, function _headerActions L146-233, function _focusHistorySearch L234-236, function _reloadFiles L237-238, function _createFileOrFolder L239-241, function _clearTerminal L242-244, function _newTerminalSession L245-249, function _showDrawer L250-315, function _showAvatarMenu L316-346, function _hostLabel L347-354, function _body L355-378, function _showMoreSheet L379-495, function _pickAgent L496-539, function _pickTools L540-603, function _openSessionScreen L604-636, function _renameSession L637-652

## lib/ui/line_icons.dart  (25 lines)
- Imports: lib/ui/theme.dart
- Imported by (6): lib/ui/chat.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/widgets.dart
- If changed, affects 15 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart ...

## lib/ui/line_icons/line_icons_painter.dart  (935 lines)
- Defines (read with exact line ranges): class LLinePainter L3+, function paint L17-37, function _path L38-43, function _draw L44-931, function shouldRepaint L932-935

## lib/ui/line_icons/line_icons_widgets.dart  (258 lines)
- Defines (read with exact line ranges): class LI L4+, class LIcon L158+, function build L173-195, class LIconButton L196+

## lib/ui/markdown.dart  (24 lines)
- Imports: lib/l10n/strings.dart, lib/ui/line_icons.dart, lib/ui/theme.dart
- Imported by (3): lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/parts.dart
- If changed, affects 9 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/markdown/markdown_code_block.dart  (207 lines)
- Defines (read with exact line ranges): function _parse L3-8, function flushPara L9-121, class _CodeBlock L122+, function build L127-207

## lib/ui/markdown/markdown_renderer.dart  (384 lines)
- Defines (read with exact line ranges): class Markdown L3+, function build L17-34, function _buildBlock L35-87, function _paragraph L88-97, function _listBlock L98-131, function _bulletMarker L132-136, function _table L137-194, function _rich L195-217, function _firstFrom L218-222, function _inlineSpans L223-266, function _makeSpan L267-299, function _linkSpan L300-322, function _codeStyle L323-342, class _Kind L343+, class _Block L345+, function _parseCached L373-384

## lib/ui/models_page.dart  (426 lines)
- Defines (read with exact line ranges): class ModelsPage L13+, function createState L17-19, class _ModelsPageState L20+, function initState L26-33, function dispose L34-39, function build L40-244, class _AgentDropdown L245+, class _ProviderBlock L278+, class _ModelTag L408+
- Imports: lib/api/client.dart, lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (2): lib/ui/chat.dart, lib/ui/home.dart
- If changed, affects 6 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/parts.dart  (24 lines)
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/line_icons.dart, lib/ui/markdown.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (2): lib/ui/chat.dart, lib/ui/diff_page.dart
- If changed, affects 8 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/parts/parts_file_agent_diff.dart  (266 lines)
- Defines (read with exact line ranges): class _FilePart L3+, function build L8-46, class _AgentPart L47+, class _RetryPart L69+, class _UnknownPart L101+, class DiffText L133+, class ThinkingGroup L185+

## lib/ui/parts/parts_tool_tile.dart  (388 lines)
- Defines (read with exact line ranges): class _Collapsible L3+, function createState L18-20, class _CollapsibleState L21+, function build L25-120, class ToolTile L121+, class _InputBlock L171+, function _pretty L193-203, function _isExternalPermissionError L204-239, class _OutputBlock L240+, class _OutputBlockState L249+

## lib/ui/parts/parts_tool_timeline.dart  (323 lines)
- Defines (read with exact line ranges): class ToolTimeline L10+, function createState L15-17, class _ToolTimelineState L18+, function build L23-74, function _buildStep L75-214, class PartTile L215+, function _firstLine L316-323

## lib/ui/primitives.dart  (25 lines)
- Imports: lib/ui/theme.dart
- Imported by (14): lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart, lib/ui/terminal_page.dart ...
- If changed, affects 15 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...

## lib/ui/primitives/primitives_buttons_cards.dart  (401 lines)
- Defines (read with exact line ranges): class OCAccent L6+, function at L59-65, class OCButtonVariant L66+, class OCButton L94+, function createState L121-123, class _OCButtonState L124+, function build L267-339, class OCCardVariant L340+, class OCCard L352+

## lib/ui/primitives/primitives_cells_controls.dart  (412 lines)
- Defines (read with exact line ranges): class OCInnerCell L5+, function build L29-57, class OCIconTile L58+, class OCStatus L132+, class OCAvatar L137+, class OCAvatarStack L222+, class OCToggle L295+, class OCSegmentedControl L368+, class OCSegment L406+

## lib/ui/primitives/primitives_progress_chip.dart  (325 lines)
- Defines (read with exact line ranges): class _SegmentItem L3+, function build L17-74, class OCProgressBar L75+, class OCProgressRing L127+, class _RingPainter L192+, function paint L206-233, function shouldRepaint L234-247, class OCChip L248+

## lib/ui/primitives/primitives_rows_skeleton.dart  (408 lines)
- Defines (read with exact line ranges): class OCListRow L10+, function build L55-135, class OCBreadcrumbs L136+, class OCFilterButton L246+, class OCSkeleton L306+, function createState L319-321, class _OCSkeletonState L322+, function dispose L330-353, class OCSkeletonList L354+

## lib/ui/prompts.dart  (17 lines)
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/line_icons.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (3): lib/main.dart, lib/ui/chat.dart, lib/ui/home.dart
- If changed, affects 7 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/prompts/prompts_permission.dart  (323 lines)
- Defines (read with exact line ranges): class PromptOverlay L11+, function build L15-58, function showPendingPrompt L59-73, class _CommandBox L74+, function createState L79-81, class _CommandBoxState L82+, class _PermissionFacts L162+, class _PermissionCard L245+

## lib/ui/prompts/prompts_question.dart  (343 lines)
- Defines (read with exact line ranges): class _QuestionCard L3+, function createState L8-10, class _QuestionCardState L11+, function dispose L18-24, function _toggle L25-40, function build L41-125, function _question L126-263, class _SessionLine L264+, class ShareCard L313+

## lib/ui/sessions_page.dart  (18 lines)
- Imports: lib/api/client.dart, lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/sessions_page/sessions_page_main.dart  (392 lines)
- Defines (read with exact line ranges): class SessionsPage L3+, function createState L7-9, class SessionsPageState L10+, function focusSearch L22-23, function clearSearch L24-30, function dispose L31-39, function build L40-62, class _SessionsHeader L63+, function visibleSessions L167-187, class _SessionsList L188+, class _SessionsListState L197+, function _pushTileErrorGuard L299-310, function _popTileErrorGuard L311-328, class _GuardedSessionTile L329+, class _GuardedSessionTileState L338+, function initState L340-365, class _BrokenSessionRow L366+

## lib/ui/sessions_page/sessions_page_tiles.dart  (373 lines)
- Defines (read with exact line ranges): class _SessionTile L3+, function build L13-118, function _showActions L119-213, function _showChildren L214-277, class _GroupedSessionList L278+, function _bucket L317-328, class _Row L329+, class _GroupHeaderDelegate L339+, function shouldRebuild L371-373

## lib/ui/settings_page.dart  (24 lines)
- Imports: lib/api/client.dart, lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart, lib/voice/voice_scope.dart, lib/voice/voice_service.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/settings_page/settings_page_body.dart  (492 lines)
- Defines (read with exact line ranges): class SettingsPage L3+, function createState L7-9, class _SettingsPageState L10+, function initState L12-17, function build L18-366, function _editServer L367-429, function _addMcp L430-492

## lib/ui/settings_page/settings_page_sections.dart  (339 lines)
- Defines (read with exact line ranges): class _Group L14+, function build L19-49, class _GroupDivider L50+, class _Providers L59+, function _addKey L131-169, class _ConfigEditor L170+, function createState L175-177, class _ConfigEditorState L178+, function _pretty L183-192, function didUpdateWidget L193-198, function dispose L199-258, class _StatusRow L259+, class _VoiceSettings L287+

## lib/ui/settings_page/settings_page_voice_tiles.dart  (370 lines)
- Defines (read with exact line ranges): class _VoiceLanguageTile L7+, function createState L13-15, class _VoiceLanguageTileState L16+, function initState L21-25, function _load L26-35, function build L36-85, function _pick L86-132, class _VoiceRateTile L133+, class _RateStep L203+, class _VoiceMicTile L253+, class _VoiceEngineTile L302+, class _ActionTile L333+

## lib/ui/terminal_page.dart  (305 lines)
- Defines (read with exact line ranges): class TerminalPage L10+, function createState L14-16, class TerminalPageState L17+, function clear L43-49, function newSession L50-57, function dispose L58-64, function _append L65-72, function _run L73-98, function build L99-301, function _terminalStyle L302-305
- Imports: lib/l10n/strings.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/theme.dart  (16 lines)
- Imported by (18): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/line_icons.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/primitives.dart ...
- If changed, affects 18 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/line_icons.dart, lib/ui/markdown.dart, lib/ui/models_page.dart ...

## lib/ui/theme/theme_build_theme.dart  (280 lines)
- Defines (read with exact line ranges): function _buildTheme L3-253, function _fieldBorder L254-259, function _textTheme L260-280

## lib/ui/theme/theme_colors.dart  (220 lines)
- Defines (read with exact line ranges): class OCColors L10+

## lib/ui/theme/theme_radius_typography.dart  (346 lines)
- Defines (read with exact line ranges): class OCRadius L4+, class OCMotion L57+, class OCTypography L94+, function _wght L123-127, function _sans L128-151, function _serif L152-169, function _mono L170-270, function numeric L271-283, function mono L284-295, function monoSmall L296-298, function monoLarge L299-302, function code L303-306, function codeBlock L307-331, class _TextStyleExt L332+, function withColor L333-344, function buildAppTheme L345-346

## lib/ui/theme/theme_tokens.dart  (406 lines)
- Defines (read with exact line ranges): class OCTokens L12+, function of L152-155, function copyWith L156-224, function lerp L225-273, class OCShadow L274+, class OCGradient L317+, class OCTokensX L348+, class OCSpace L353+

## lib/ui/todos_page.dart  (257 lines)
- Defines (read with exact line ranges): class TodosPage L11+, function createState L15-17, class _TodosPageState L18+, function initState L20-31, function build L32-49, class _TodosBody L50+, class _TodoTile L151+, function _leading L199-221, class _ActivePulse L222+, class _ActivePulseState L230+, function dispose L244-257
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/widgets.dart  (16 lines)
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/line_icons.dart, lib/ui/primitives.dart, lib/ui/theme.dart
- Imported by (12): lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart, lib/ui/todos_page.dart
- If changed, affects 13 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...

## lib/ui/widgets/widgets_header_button.dart  (149 lines)
- Defines (read with exact line ranges): class HeaderButton L4+, function build L21-56, class CountBadge L57+, class InfoRow L90+, function toolIcon L128-141, function toolColor L142-149

## lib/ui/widgets/widgets_headers_pills.dart  (419 lines)
- Defines (read with exact line ranges): class SectionTitle L4+, function build L10-34, class Mono L35+, function ocReduceMotion L68-74, class OcLinkState L75+, class StatusPill L97+, function createState L119-121, class _StatusPillState L122+, function initState L130-135, function didUpdateWidget L136-140, function _sync L141-150, function dispose L151-260, function ocLinkState L261-277, class HeaderAction L278+, class AppHeader L317+

## lib/ui/widgets/widgets_navigation_feedback.dart  (415 lines)
- Defines (read with exact line ranges): function pushScreen L9-24, function showToast L25-41, class _ToastWidget L42+, function createState L53-55, class _ToastWidgetState L56+, function dispose L64-69, function build L70-130, function showSnack L131-136, function showUndoSnack L137-147, function copyToClipboard L148-158, class EmptyHint L159+, class LoadingView L218+, class ConnectionErrorView L240+, function promptText L343-381, function confirmDialog L382-415

## lib/voice/voice_scope.dart  (32 lines)
- Defines (read with exact line ranges): class VoiceScope L12+, function of L19-25, function read L26-32
- Imports: lib/voice/voice_service.dart
- Imported by (3): lib/main.dart, lib/ui/chat.dart, lib/ui/settings_page.dart
- If changed, affects 7 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/voice/voice_service.dart  (24 lines)
- Imports: lib/state/store.dart
- Imported by (4): lib/main.dart, lib/ui/chat.dart, lib/ui/settings_page.dart, lib/voice/voice_scope.dart
- If changed, affects 8 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart, lib/voice/voice_scope.dart

## lib/voice/voice_service/voice_service_conversation.dart  (238 lines)
- Defines (read with exact line ranges): class VoiceServiceConversation L9+, function _finishUtterance L10-26, function _commitUtterance L27-41, function _sendAndWait L42-70, function _onEmptyUtterance L71-87, function toggleConversation L88-95, function startConversation L96-116, function endConversation L117-137, function _onSessionChanged L138-154, function _handleTail L155-184, function _lastAssistantMessage L185-192, function _checkInactivity L193-198, function _resumeLoop L199-212, function _relisten L213-238

## lib/voice/voice_service/voice_service_core.dart  (267 lines)
- Defines (read with exact line ranges): class VoiceService L15+, function dispose L110-143, function _onStore L144-184, function _messageText L185-197, function _normalize L198-209, function plainSpeech L210-249, function _split L250-267

## lib/voice/voice_service/voice_service_dictation.dart  (234 lines)
- Defines (read with exact line ranges): class VoiceServiceDictation L9+, function _startRecognizer L10-54, function toggleDictation L55-65, function stopDictation L66-98, function _beginListen L99-142, function _stopRecognizer L143-154, function _onLevel L155-162, function _onResult L163-187, function _onStatus L188-202, function _onRecognizerError L203-234

## lib/voice/voice_service/voice_service_lifecycle.dart  (168 lines)
- Defines (read with exact line ranges): class VoiceServiceLifecycle L9+, function _go L20-33, function _fail L34-45, function _forget L46-56, function suspend L57-71, function resume L72-89, function warmUp L90-94, function _initSpeech L95-117, function _applySpeechSettings L118-129, function _loadSettings L130-143, function _persist L144-161, function _ensureRecognizer L162-168

## lib/voice/voice_service/voice_service_settings.dart  (75 lines)
- Defines (read with exact line ranges): class VoiceServiceSettings L9+, function setLanguage L23-29, function setRate L30-36, function setReadAloud L37-42, function setAutoSend L43-56, function ackIntro L57-67, function clearNotice L68-75

## lib/voice/voice_service/voice_service_speech.dart  (176 lines)
- Defines (read with exact line ranges): class VoiceServiceSpeech L9+, function speak L15-49, function stopSpeaking L50-56, function _stopSpeaking L57-75, function testVoice L76-83, function _runQueue L84-106, function _onSpeakStart L107-112, function _onSpeakDone L113-114, function _onSpeakError L115-119, function _completePending L120-130, function _armWatchdog L131-139, function _finishSpeaking L140-153, function _interruptToListen L154-160, function _isEcho L161-176

## lib/voice/voice_service/voice_service_state.dart  (110 lines)
- Defines (read with exact line ranges): class VoiceServiceState L9+, function _supersedeListen L49-52, function _superseded L53-75, function locales L76-100, function openMicrophoneSettings L101-110
- WHY: the last attempt stopped, if it stopped badly. :12
- WHY: hands-free turned itself off. The UI shows it once, then calls :15

## lib/voice/voice_service/voice_service_types.dart  (141 lines)
- Defines (read with exact line ranges): class VoiceLocale L7+, class VoicePhase L25+, class VoiceFailure L52+
- WHY: voice stopped, in terms the UI turns into one calm sentence. :51
