# FILES - one card per file (read this instead of opening files blindly)
Format: Defines / Imports / Imported by / Calls into / If changed -> affected files / Issues / Notes

## android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java  (70 lines)
- Defines (read with exact line ranges): function registerWith L17-70

## deploy.py  (201 lines)
- Defines (read with exact line ranges): function run L38-52, function fail L53-57, function norm L58-66, function allowed L67-76, function staged_files L77-82, function check_paths L83-104, function main L105-201

## lib/api/client.dart  (24 lines)
- Imports: lib/l10n/strings.dart, lib/models/models.dart
- Imported by (8): lib/state/store.dart, lib/ui/chat.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart
- If changed, affects 19 file(s): lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart ...

## lib/api/client/client_oc_client.dart  (44 lines)
- Defines (read with exact line ranges): class ApiException L3+, function toString L13-16, function _parseBytes L17-25, class OcClient L26+

## lib/api/client/client_oc_client_http.dart  (212 lines)
- Defines (read with exact line ranges): class OcClientHttp L8+, function _headers L13-22, function _u L23-36, function _decode L37-79, function _sendOnce L80-127, function _send L128-143, function get L144-153, function post L154-167, function patch L168-181, function put L182-195, function delete L196-209, function close L210-212

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

## lib/l10n/strings.dart  (1164 lines)
- Defines (read with exact line ranges): class S L9+, function serverOnlineVersion L111-190, function composerModelAgent L191-196, function toolRunning L197-197, function toolDone L198-204, function moreToolsCount L205-250, function filesCount L251-251, function messageCount L252-252, function tokensUsed L253-280, function sessionsDeleteBody L281-299, function historyFiles L300-307, function cmdArgs L308-308, function cmdUseSkill L309-309, function cmdUseLabel L310-310, function partsAgent L311-327, function diffAppliesTo L328-360, function filesDeleteBody L361-364, function filesNameLabel L365-366, function filesEmptyName L367-368, function filesNameHint L369-385, function setPermExternalTitle L386-387, function setPermExternalBody L388-391, function setPassword L392-402, function filesExists L403-403, function filesDeleteFailed L404-404, function filesFolderFailed L405-407, function added L408-411, function codeLines L412-412, function codeShowAll L413-433, function netTimeout L434-434, function netUnreachable L435-440, function permSuggestingRules L441-450, function filesChangedCount L451-476, function modelsContext L477-477, function modelsSelected L478-482, function setMcpLabel L483-502, function partsThoughtFor L503-504, function partsThinkingLines L505-511, function waitingYou L512-516, function promptSemantics L517-518 ...
- Imported by (17): lib/api/client.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...
- If changed, affects 21 file(s): lib/api/client.dart, lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart ...

## lib/main.dart  (114 lines)
- Defines (read with exact line ranges): function main L14-18, class OpenCodeApp L19+, function createState L23-25, class _OpenCodeAppState L26+, function initState L35-45, function dispose L46-53, function didChangeAppLifecycleState L54-80, function build L81-114
- Imports: lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/home.dart, lib/ui/prompts.dart, lib/ui/theme.dart, lib/voice/voice_scope.dart, lib/voice/voice_service.dart, lib/widgets/buddy.dart

## lib/models/models.dart  (9 lines)
- Imported by (15): lib/api/client.dart, lib/api/events.dart, lib/state/store.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart ...
- If changed, affects 21 file(s): lib/api/client.dart, lib/api/events.dart, lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart ...

## lib/models/models/models_server_info.dart  (444 lines)
- Defines (read with exact line ranges): class ModelInfo L3+, class Todo L46+, class FileNode L75+, class FileDiff L97+, class CommandInfo L123+, class SkillInfo L144+, class NamedStatus L159+, class VcsInfo L182+, class ServerPaths L194+, class PermissionReq L215+, function _fmt L336-342, class QuestionOption L343+, class QuestionItem L350+, class QuestionReq L373+, function fmtBytes L403-408, function fmtTime L409-414, function fmtAge L415-424, function fmtDuration L425-432, function baseName L433-437, function dirName L438-444

## lib/models/models/models_session_message.dart  (401 lines)
- Defines (read with exact line ranges): function asMap L3-6, function asList L7-8, function asInt L9-12, function asStr L13-14, function asDouble L15-17, function asBool L18-21, class Tokens L22+, class SessionSummary L50+, class PendingPrompt L71+, class Session L94+, function toMap L153-157, class Message L158+, class ToolStatus L236+, class Part L238+, function _short L364-373, class Agent L374+
- WHY: the raw message needs this before the UI can show anything. :218

## lib/state/store.dart  (32 lines)
- Imports: lib/api/client.dart, lib/api/events.dart, lib/db/chat_db.dart, lib/l10n/strings.dart, lib/models/models.dart, lib/widgets/buddy.dart
- Imported by (17): lib/main.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart ...
- If changed, affects 18 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart ...

## lib/state/store/store_ocstore.dart  (396 lines)
- Defines (read with exact line ranges): class OcStore L5+, function setMascot L83-92, function _buddyCall L93-98, function _buddyDone L99-104, function _buddyError L105-110, function _buddyConnecting L111-115, function _buddyConnected L116-121, function _buddyDisconnected L122-126, function _buddyPart L127-147, function _buddyToolEnded L148-152, function _anyToolRunning L153-166, function notifyListeners L167-219, function _messageText L220-243, function _stripEchoedOptimistic L244-339, function _parentDir L340-345, function _shellQuote L346-380, function dispose L381-396

## lib/state/store/store_ocstore_cache.dart  (171 lines)
- Defines (read with exact line ranges): class OcStoreCache L9+, function _scheduleNotify L17-31, function _scheduleMessageNotify L32-50, function _debouncedTodos L51-65, function _dbRow L66-76, function _isCacheable L77-91, function _mergeHistory L92-112, function _cachedHistory L113-130, function _scheduleFlush L131-148, function _flushHistory L149-164, function _persistHistory L165-171

## lib/state/store/store_ocstore_connection.dart  (413 lines)
- Defines (read with exact line ranges): class OcStoreConnection L14+, function boot L24-46, function _persist L47-63, function setServer L64-71, function connect L72-145, function _markAlive L146-161, function _healthFailed L162-173, function _offlineMessage L174-182, function _verifyReachability L183-253, function _startStream L254-275, function _onStreamStatus L276-311, function _resyncMessages L312-344, function refreshServerInfo L345-354, function refreshCatalog L355-386, function setModel L387-393, function setAgent L394-399, function toggleTool L400-413
- NOTE: there is deliberately no storage-permission gate here. File writes go :16
- TODO: updates that landed while the socket was down are gone with it, and :299

## lib/state/store/store_ocstore_events.dart  (275 lines)
- Defines (read with exact line ranges): class OcStoreEvents L9+, function handleEvent L14-31, function _repliedId L32-40, function _promptParseFailed L41-48, function _handleEvent L49-267, function _errorText L268-275

## lib/state/store/store_ocstore_history.dart  (231 lines)
- Defines (read with exact line ranges): class OcStoreHistory L9+, function _prependHistory L12-28, function _widenHistory L29-56, function loadOlderMessages L57-97, function addAttachment L98-102, function removeAttachment L103-107, function clearAttachments L108-112, function _partPayload L113-129, function sendOrQueue L130-144, function _flushQueue L145-156, function send L157-231

## lib/state/store/store_ocstore_messages.dart  (244 lines)
- Defines (read with exact line ranges): class OcStoreMessages L9+, function _isCurrent L12-14, function _messageById L15-22, function _optimisticIndex L23-30, function _clearLocalEcho L31-35, function _upsertMessage L36-62, function _upsertPart L63-126, function _applyDelta L127-148, function _removePart L149-166, function _removeMessage L167-182, function _upsertSession L183-198, function _toast L199-199, function takeToast L200-206, function reconnectStream L207-215, function pauseConnections L216-234, function resumeConnections L235-244

## lib/state/store/store_ocstore_prompts.dart  (196 lines)
- Defines (read with exact line ranges): class OcStorePrompts L9+, function loadPending L14-54, function resyncPrompts L55-82, function _resyncPromptsOnce L83-106, function answerPermission L107-127, function answerQuestion L128-140, function rejectQuestion L141-153, function _syncBuddyPermission L154-172, function _buddyPermissionFlow L173-196

## lib/state/store/store_ocstore_run.dart  (266 lines)
- Defines (read with exact line ranges): class OcStoreRun L9+, function _touchActivity L10-14, function _startBusyTimer L15-46, function _probeBusyState L47-94, function _clearBusyTimer L95-107, function _settleStuckStreaming L108-118, function _sendParts L119-168, function runCommand L169-207, function summarize L208-217, function revert L218-228, function unrevert L229-239, function initAgents L240-266

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

## lib/ui/buddy_avatar.dart  (682 lines)
- Defines (read with exact line ranges): class BuddyChar L17+, class BuddyMood L19+, class BuddyBadge L39+, function build L46-56, class BuddyAvatar L57+, function createState L75-77, class _BuddyAvatarState L78+, function dispose L86-111, class _BuddyPainter L112+, function _w L131-132, function _text L133-155, function paint L156-184, function _seated L185-297, function _running L298-369, function _head L370-532, function _effects L533-627, function shouldRepaint L628-632, class BuddyDemoPage L633+, class _BuddyDemoPageState L640+
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

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

## lib/ui/chat/chat_message.dart  (395 lines)
- Defines (read with exact line ranges): class SuggestionCard L8+, function createState L21-23, class _SuggestionCardState L24+, function build L28-108, class _MessageTile L109+, class _MessageTileState L129+, function didChangeDependencies L142-146, function _signature L147-170, function _openMenu L171-174, function _buildContent L175-238, function _userBubble L239-296, function _assistantBlock L297-372, class _AssistantAvatar L373+

## lib/ui/chat/chat_message_actions.dart  (283 lines)
- Defines (read with exact line ranges): function showMessageMenu L8-101, class _SheetRow L102+, function build L115-138, class _IncomingFileChip L139+, class _MessageActions L210+, class _ActionDot L244+

## lib/ui/chat/chat_page.dart  (388 lines)
- Defines (read with exact line ranges): class ChatPage L3+, function createState L7-14, class _ChatPageState L15+, function initState L67-88, function dispose L89-107, function _insertUtterance L108-122, function _onStoreChange L123-135, function _chatMessageCount L136-146, function _onScroll L147-158, function _bumpUnread L159-166, function _handleNotification L167-189, function _setFollow L190-199, function _queueAutoScroll L200-213, function _runAutoScroll L214-224, function _jumpToLatest L225-243, function _loadOlderMessages L244-266, function _syncFollow L267-301, function build L302-340, function _sendSuggestion L341-349, function _send L350-388

## lib/ui/chat/chat_reply_meta.dart  (187 lines)
- Defines (read with exact line ranges): class _ReplyMeta L5+, function build L11-31, function _turnOf L32-44, function _replyText L45-56, class _ReplyActions L57+, class _ReadAloudAction L105+, class _ActionBtn L140+

## lib/ui/chat/chat_run_progress.dart  (368 lines)
- Defines (read with exact line ranges): class _WorkingStrip L15+, function createState L21-23, class _WorkingStripState L24+, function initState L39-45, function _armSlowTimer L46-55, function dispose L56-61, function build L62-194, class _PromptChip L195+, class _QueuedStrip L235+, function isFreeModel L268-281, class _RunProgressLine L282+, class _IndeterminateBar L309+, class _IndeterminateBarState L317+, class _BarPainter L346+, function paint L352-365, function shouldRepaint L366-368
- WHY: * the agent is quiet. A pending :9

## lib/ui/chat/chat_send_button.dart  (170 lines)
- Defines (read with exact line ranges): class _SendButton L5+, function build L24-103, function _dictation L104-116, class _CircleButton L117+

## lib/ui/chat/chat_status.dart  (136 lines)
- Defines (read with exact line ranges): class _BusyBar L3+, function build L8-19, class _InlineError L20+, function _isCancellation L28-80, class _TypingDots L81+, function createState L85-87, class _TypingDotsState L88+, function dispose L96-136

## lib/ui/chat/chat_transcript.dart  (273 lines)
- Defines (read with exact line ranges): class _BusyBarWidget L4+, function build L8-25, class _ChatMessages L26+, function _buildList L59-173, function _showsSomething L174-179, class _JumpToLatest L180+, class _LoadOlderButton L248+

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

## lib/ui/home.dart  (33 lines)
- Imports: lib/api/client.dart, lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/buddy_avatar.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/line_icons.dart, lib/ui/models_page.dart, lib/ui/primitives.dart, lib/ui/prompts.dart
- Imported by (1): lib/main.dart
- If changed, affects 1 file(s): lib/main.dart

## lib/ui/home/home_avatar_drawer.dart  (411 lines)
- Defines (read with exact line ranges): class _AvatarButton L5+, function createState L15-17, class _AvatarButtonState L18+, function initState L28-34, function _startPulse L35-43, function didUpdateWidget L44-55, function dispose L56-62, function build L63-127, class _PromptCountBadge L128+, class _DrawerBadge L178+, class _Drawer L213+

## lib/ui/home/home_drawer_rows.dart  (367 lines)
- Defines (read with exact line ranges): class _DrawerNavRow L5+, function build L23-82, class _DrawerRecentRow L83+, class _DrawerFooter L170+, class _DrawerIconButton L320+

## lib/ui/home/home_server_menu.dart  (412 lines)
- Defines (read with exact line ranges): class _ServerMenu L8+, function build L34-121, class _ServerMenuHeader L122+, class _MenuRow L234+, class _SheetOption L329+, class _SheetGroup L390+

## lib/ui/home/home_shell.dart  (744 lines)
- Defines (read with exact line ranges): class _BuddyLink L10+, function createState L17-19, class _BuddyLinkState L20+, function initState L26-32, function didUpdateWidget L33-41, function dispose L42-47, function _sync L48-86, function build L87-90, class _Tab L91+, class HomeShell L104+, class HomeShellState L111+, function goTo L134-137, function _navigate L138-142, function _pushAndClose L143-154, function _todosActions L155-163, function _worktree L164-236, function _headerActions L237-324, function _focusHistorySearch L325-327, function _reloadFiles L328-329, function _createFileOrFolder L330-332, function _clearTerminal L333-335, function _newTerminalSession L336-340, function _showDrawer L341-406, function _showAvatarMenu L407-438, function _hostLabel L439-446, function _body L447-470, function _showMoreSheet L471-587, function _pickAgent L588-631, function _pickTools L632-695, function _openSessionScreen L696-728, function _renameSession L729-744

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

## lib/ui/markdown/markdown_code_block.dart  (364 lines)
- Defines (read with exact line ranges): function _parse L3-8, function flushPara L9-121, class _CodeBlock L122+, function createState L127-129, class _CodeBlockState L130+, function _toggle L137-139, function build L140-364

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

## lib/ui/parts/parts_file_agent_diff.dart  (267 lines)
- Defines (read with exact line ranges): class _FilePart L3+, function build L8-46, class _AgentPart L47+, class _RetryPart L69+, class _UnknownPart L101+, class DiffText L133+, class ThinkingGroup L185+

## lib/ui/parts/parts_tool_tile.dart  (450 lines)
- Defines (read with exact line ranges): class _Collapsible L3+, function createState L23-25, class _CollapsibleState L26+, function _buildCompact L31-85, function build L86-182, class ToolTile L183+, class _InputBlock L233+, function _pretty L255-265, function _isExternalPermissionError L266-301, class _OutputBlock L302+, class _OutputBlockState L311+

## lib/ui/parts/parts_tool_timeline.dart  (351 lines)
- Defines (read with exact line ranges): class ToolTimeline L11+, function createState L16-18, class _ToolTimelineState L19+, function build L24-70, function _buildStep L71-242, class PartTile L243+, function _firstLine L344-351

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

## lib/ui/prompts.dart  (18 lines)
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/line_icons.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart, lib/widgets/buddy.dart
- Imported by (3): lib/main.dart, lib/ui/chat.dart, lib/ui/home.dart
- If changed, affects 7 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/prompts/prompts_permission.dart  (326 lines)
- Defines (read with exact line ranges): class PromptOverlay L11+, function build L15-61, function showPendingPrompt L62-76, class _CommandBox L77+, function createState L82-84, class _CommandBoxState L85+, class _PermissionFacts L165+, class _PermissionCard L248+

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

## lib/ui/settings_page.dart  (25 lines)
- Imports: lib/api/client.dart, lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart, lib/voice/voice_scope.dart, lib/voice/voice_service.dart, lib/widgets/buddy.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/settings_page/settings_page_body.dart  (543 lines)
- Defines (read with exact line ranges): class SettingsPage L3+, function createState L7-9, class _SettingsPageState L10+, function initState L12-17, function build L18-417, function _editServer L418-480, function _addMcp L481-543

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

## lib/ui/velo_avatar.dart  (384 lines)
- Defines (read with exact line ranges): class VeloMood L15+, class VeloBadge L23+, function build L27-32, class VeloAvatar L33+, function createState L39-41, class _VeloAvatarState L42+, function dispose L47-67, class _VeloPainter L68+, function _w L77-78, function _text L79-90, function _ellipse L91-99, function paint L100-187, function _fin L188-202, function _face L203-310, function _extrasBehind L311-337, function _extrasFront L338-381, function shouldRepaint L382-384

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

## lib/widgets/buddy.dart  (755 lines)
- Defines (read with exact line ranges): class BuddyChar L26+, class BuddyMood L28+, class BuddyBadge L36+, function build L41-47, class BuddyAvatar L48+, function createState L63-65, class _BuddyAvatarState L66+, function dispose L71-91, class _BuddyPainter L92+, function _w L110-111, function _text L112-124, function paint L125-151, function _seated L152-220, function _running L221-252, function _head L253-352, function _effects L353-419, function shouldRepaint L420-423, class BuddyDemoPage L424+, class _BuddyDemoPageState L430+, class PermissionDecision L456+, class PermissionRequest L458+, class BuddyController L468+, function character L482-486, function _set L487-506, function connecting L507-507, function connected L508-508, function disconnected L509-512, function userSent L513-515, function thinking L516-518, function writing L519-521, function toolStart L522-533, function toolEnd L534-536, function done L537-539, function error L540-543, function poke L544-552, function askPermission L553-563, function answerPermission L564-576, function runDemo L577-599, class BuddyOverlay L600+, class _PermissionCard L686+
- Imported by (4): lib/main.dart, lib/state/store.dart, lib/ui/prompts.dart, lib/ui/settings_page.dart
- If changed, affects 19 file(s): lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart ...
