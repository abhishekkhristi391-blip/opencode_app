# FILES - one card per file (read this instead of opening files blindly)
Format: Defines / Imports / Imported by / Calls into / If changed -> affected files / Issues / Notes

## deploy.py  (94 lines)
- Defines (read with exact line ranges): function run L21-35, function main L36-86, function shutil_which L87-94

## lib/api/client.dart  (874 lines)
- Defines (read with exact line ranges): class ApiException L12+, function toString L22-25, function _parseBytes L26-32, class OcClient L33+, function _headers L55-62, function _u L63-76, function _decode L77-119, function _send L120-147, function get L148-156, function post L157-170, function patch L171-184, function put L185-198, function delete L199-212, function close L213-218, function events L219-267, function eventsAutoReconnect L268-289, function paths L290-292, function vcs L293-294, function disposeInstance L295-297, function upgrade L298-301, function log L302-311, function config L312-313, function patchConfig L314-316, function configProviders L317-325, function providers L326-328, function providerAuthMethods L329-339, function providerAuthUrl L340-351, function setApiKey L352-359, function removeAuth L360-363, function agents L364-368, function sessions L369-373, function createSession L374-392, function session L393-395, function deleteSession L396-398, function renameSession L399-403, function childSessions L404-408, function sessionStatus L409-411, function todos L412-416, function abort L417-420, function fork L421-425 ...
- Imports: lib/models/models.dart
- Imported by (3): lib/state/store.dart, lib/ui/models_page.dart, lib/ui/settings_page.dart
- If changed, affects 16 file(s): lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart ...

## lib/api/events.dart  (213 lines)
- Defines (read with exact line ranges): class OcEvent L10+, class EventStream L44+, function start L79-84, function reconnect L85-91, function _connect L92-157, function _handleFrame L158-174, function _setConnected L175-180, function _scheduleRetry L181-199, function stop L200-213
- Imports: lib/models/models.dart
- Imported by (1): lib/state/store.dart
- If changed, affects 16 file(s): lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart ...

## lib/db/chat_db.dart  (235 lines)
- Defines (read with exact line ranges): class ChatDB L21+, function _init L42-64, function _createMessages L65-79, function _createSessions L80-93, function _enqueue L94-106, function _sortKey L107-117, function _writeRow L118-131, function upsertMessages L132-150, function deleteMessage L151-162, function loadMessages L163-183, function clearSession L184-193, function saveSessions L194-211, function saveSession L212-216, function deleteSessionRow L217-224, function loadSessions L225-235
- Imported by (1): lib/state/store.dart
- If changed, affects 16 file(s): lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart ...

## lib/l10n/strings.dart  (557 lines)
- Defines (read with exact line ranges): class S L9+, function serverOnlineVersion L111-147, function chatWelcomeSubtitle L148-173, function composerModelAgent L174-180, function toolRunning L181-181, function toolDone L182-188, function moreToolsCount L189-233, function filesCount L234-234, function messageCount L235-235, function tokensUsed L236-263, function sessionsDeleteBody L264-266, function sessionsCount L267-267, function sessionsCountOne L268-268, function forkCreated L269-304, function fileStats L305-329, function diffAddedRemoved L330-345, function tasksProgress L346-346, function tasksProgressSemantics L347-378, function useSkillPrompt L379-467, function mcpCount L468-468, function skillsCount L469-469, function toolsCount L470-470, function settingsConnectedVersion L471-552, function label L553-553, function slashCommand L554-554, function errorText L555-557
- Imported by (5): lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/home.dart, lib/ui/sessions_page.dart, lib/ui/widgets.dart
- If changed, affects 14 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...

## lib/main.dart  (71 lines)
- Defines (read with exact line ranges): function main L8-12, class OpenCodeApp L13+, function createState L17-19, class _OpenCodeAppState L20+, function initState L24-30, function dispose L31-37, function didChangeAppLifecycleState L38-54, function build L55-71
- Imports: lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/home.dart, lib/ui/theme.dart

## lib/models/models.dart  (743 lines)
- Defines (read with exact line ranges): function asMap L5-8, function asList L9-10, function asInt L11-14, function asStr L15-16, function asDouble L17-19, function asBool L20-23, class Tokens L24+, class SessionSummary L52+, class Session L65+, function toMap L124-128, class Message L129+, class ToolStatus L207+, class Part L209+, function _short L335-344, class Agent L345+, class ModelInfo L373+, class Todo L416+, class FileNode L439+, class FileDiff L461+, class CommandInfo L487+, class SkillInfo L508+, class NamedStatus L523+, class VcsInfo L546+, class ServerPaths L558+, class PermissionReq L579+, function _fmt L640-646, class QuestionOption L647+, class QuestionItem L654+, class QuestionReq L677+, function fmtBytes L702-707, function fmtTime L708-713, function fmtAge L714-723, function fmtDuration L724-731, function baseName L732-736, function dirName L737-743
- Imported by (14): lib/api/client.dart, lib/api/events.dart, lib/state/store.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart ...
- If changed, affects 19 file(s): lib/api/client.dart, lib/api/events.dart, lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart ...
- WHY: the raw message needs this before the UI can show anything. :189

## lib/state/store.dart  (1783 lines)
- Defines (read with exact line ranges): class ChatMessage L14+, class PendingAttachment L39+, class OcStore L54+, function setShowTokensInChat L102-129, function _scheduleNotify L130-138, function _debouncedTodos L139-151, function _dbRow L152-162, function _isCacheable L163-177, function _mergeHistory L178-196, function _cachedHistory L197-222, function _scheduleFlush L223-240, function _flushHistory L241-256, function _persistHistory L257-271, function boot L272-287, function _persist L288-304, function setServer L305-312, function connect L313-347, function _startStream L348-371, function _resyncMessages L372-397, function refreshServerInfo L398-407, function refreshCatalog L408-439, function setModel L440-446, function setAgent L447-452, function toggleTool L453-469, function refreshSessions L470-496, function _persistSessions L497-507, function _restoreSessionsFromCache L508-525, function newSession L526-543, function openSession L544-602, function _safeSession L603-611, function renameSession L612-620, function deleteSession L621-638, function forkSession L639-649, function shareSession L650-659, function unshareSession L660-668, function abortSession L669-686, function refreshTodos L687-697, function refreshDiff L698-721, function _prependHistory L722-735, function _widenHistory L736-760 ...
- Imports: lib/api/client.dart, lib/api/events.dart, lib/db/chat_db.dart, lib/models/models.dart
- Imported by (11): lib/main.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart
- If changed, affects 15 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart ...
- NOTE: there is deliberately no storage-permission gate here. File writes go :264

## lib/ui/about_page.dart  (119 lines)
- Defines (read with exact line ranges): class AboutPage L10+, function build L14-119
- Imports: lib/l10n/strings.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/app_scope.dart  (22 lines)
- Defines (read with exact line ranges): class AppScope L6+, function of L10-16, function read L17-22
- Imports: lib/state/store.dart
- Imported by (14): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart ...
- If changed, affects 14 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...

## lib/ui/chat.dart  (2150 lines)
- Defines (read with exact line ranges): class ChatPage L21+, function createState L25-32, class _ChatPageState L33+, function initState L76-88, function dispose L89-99, function _onStoreChange L100-109, function _onScroll L110-118, function _handleNotification L119-141, function _setFollow L142-151, function _queueAutoScroll L152-165, function _runAutoScroll L166-176, function _jumpToLatest L177-194, function _loadOlderMessages L195-217, function _syncFollow L218-240, function build L241-268, function _sendSuggestion L269-277, function _send L278-316, class _ErrorBarWidget L317+, class _BusyBarWidget L337+, class _ChatMessages L359+, class _JumpToLatest L440+, class _LoadOlderButton L487+, class _ErrorBar L513+, class _BusyBar L551+, class _Welcome L564+, class _SuggestionCard L617+, class _MessageTile L667+, class _MessageTileState L682+, function didChangeDependencies L689-693, function _signature L694-715, function _openMenu L716-719, function _buildContent L720-765, function _userBubble L766-811, function _assistantBlock L812-853, class _ReplyMeta L854+, class _ReplyActions L880+, class _ActionBtn L915+, function showMessageMenu L958-1032, class _SheetRow L1033+, class _IncomingFileChip L1070+ ...
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/line_icons.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (3): lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/sessions_page.dart
- If changed, affects 5 file(s): lib/main.dart, lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/commands_page.dart  (224 lines)
- Defines (read with exact line ranges): class CommandsPage L13+, function build L17-44, class _CommandTile L45+, class SkillsSection L150+
- Imports: lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/markdown.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (2): lib/ui/home.dart, lib/ui/settings_page.dart
- If changed, affects 3 file(s): lib/main.dart, lib/ui/home.dart, lib/ui/settings_page.dart

## lib/ui/diff_page.dart  (483 lines)
- Defines (read with exact line ranges): class DiffPage L11+, function createState L15-17, class _DiffPageState L18+, function initState L28-32, function _load L33-79, function build L80-205, class _SessionDiffTile L206+, function _unifiedPreview L339-354, function _split L355-358, function _diffOps L359-404, function _toGitPatch L405-407, class _GitDiffView L408+
- Imports: lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/parts.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/files_page.dart  (788 lines)
- Defines (read with exact line ranges): class FilesPage L10+, function createState L14-16, class _FilesPageState L17+, function initState L27-32, function dispose L33-40, function _normDir L41-53, function _validName L54-64, function _createMenu L65-94, function _newFile L95-125, function _newFolder L126-141, function _load L142-179, function build L180-345, function _open L346-353, function _menu L354-454, function _q L455-457, function _pillBorder L458-464, class ChangedFilesPage L465+, class _FileTile L515+, function _icon L565-592, class FileEditorPage L593+, class _FileEditorPageState L601+, function _save L647-788
- Imports: lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/home.dart  (620 lines)
- Defines (read with exact line ranges): class _Tab L25+, class HomeShell L33+, function createState L37-39, class HomeShellState L40+, function goTo L59-61, function build L62-99, function _body L100-123, function _showMoreSheet L124-238, function _pickAgent L239-282, function _pickTools L283-346, function _openSessionScreen L347-371, function _renameSession L372-387, class _Header L388+, class _HeaderBtn L458+, class _BottomBar L482+, class _NavItem L518+, class _SheetOption L571+
- Imports: lib/l10n/strings.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/line_icons.dart, lib/ui/models_page.dart, lib/ui/primitives.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart, lib/ui/terminal_page.dart
- Imported by (1): lib/main.dart
- If changed, affects 1 file(s): lib/main.dart

## lib/ui/line_icons.dart  (654 lines)
- Defines (read with exact line ranges): class LI L17+, class LIcon L99+, function build L114-135, class LIconButton L136+, class LLinePainter L189+, function paint L203-223, function _path L224-229, function _draw L230-650, function shouldRepaint L651-654
- Imported by (4): lib/ui/chat.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/parts.dart
- If changed, affects 9 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/parts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/markdown.dart  (588 lines)
- Defines (read with exact line ranges): class Markdown L19+, function build L33-50, function _buildBlock L51-103, function _paragraph L104-113, function _listBlock L114-147, function _bulletMarker L148-152, function _table L153-210, function _rich L211-233, function _firstFrom L234-238, function _inlineSpans L239-282, function _makeSpan L283-315, function _linkSpan L316-338, function _codeStyle L339-355, class _Kind L356+, class _Block L358+, function _parseCached L379-390, function _parse L391-396, function flushPara L397-509, class _CodeBlock L510+
- Imports: lib/ui/line_icons.dart, lib/ui/theme.dart
- Imported by (3): lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/parts.dart
- If changed, affects 8 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/home.dart, lib/ui/parts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/models_page.dart  (371 lines)
- Defines (read with exact line ranges): class ModelsPage L11+, function createState L15-17, class _ModelsPageState L18+, function initState L24-31, function dispose L32-37, function build L38-235, class _AgentDropdown L236+, class _ProviderBlock L271+
- Imports: lib/api/client.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (2): lib/ui/chat.dart, lib/ui/home.dart
- If changed, affects 6 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/parts.dart  (822 lines)
- Defines (read with exact line ranges): class ToolTimeline L24+, function createState L29-31, class _ToolTimelineState L32+, function build L37-73, function _buildStep L74-213, class PartTile L214+, function _firstLine L315-322, class _Collapsible L323+, class _CollapsibleState L341+, class ToolTile L416+, class _InputBlock L466+, function _pretty L488-498, function _isExternalPermissionError L499-534, class _OutputBlock L535+, class _OutputBlockState L544+, class _FilePart L646+, class _AgentPart L690+, class _RetryPart L712+, class _UnknownPart L744+, class DiffText L776+
- Imports: lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/line_icons.dart, lib/ui/markdown.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (2): lib/ui/chat.dart, lib/ui/diff_page.dart
- If changed, affects 7 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/home.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/primitives.dart  (1530 lines)
- Defines (read with exact line ranges): class OCAccent L20+, function at L66-72, class OCButtonVariant L73+, class OCButton L98+, function createState L125-127, class _OCButtonState L128+, function build L271-346, class OCCardVariant L347+, class OCCard L359+, class OCInnerCell L411+, class OCIconTile L464+, class OCStatus L538+, class OCAvatar L543+, class OCAvatarStack L626+, class OCToggle L699+, class OCSegmentedControl L772+, class OCSegment L810+, class _SegmentItem L817+, class OCProgressBar L889+, class OCProgressRing L941+, class _RingPainter L998+, function paint L1012-1039, function shouldRepaint L1040-1053, class OCChip L1054+, class OCListRow L1140+, class OCBreadcrumbs L1258+, class OCFilterButton L1368+, class OCSkeleton L1428+, class _OCSkeletonState L1444+, function dispose L1452-1475, class OCSkeletonList L1476+
- Imports: lib/ui/theme.dart
- Imported by (14): lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart, lib/ui/terminal_page.dart ...
- If changed, affects 15 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...

## lib/ui/prompts.dart  (371 lines)
- Defines (read with exact line ranges): class PromptOverlay L12+, function build L16-39, class _PermissionCard L40+, class _QuestionCard L146+, function createState L151-153, class _QuestionCardState L154+, function dispose L161-167, function _toggle L168-255, function _question L256-340, class ShareCard L341+
- Imports: lib/models/models.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/sessions_page.dart  (516 lines)
- Defines (read with exact line ranges): class SessionsPage L13+, function createState L17-19, class _SessionsPageState L20+, function dispose L26-31, function build L32-47, class _SessionsHeader L48+, function visibleSessions L70-77, class _SessionsList L78+, class _SessionsListState L86+, function _pushTileErrorGuard L194-205, function _popTileErrorGuard L206-223, class _GuardedSessionTile L224+, class _GuardedSessionTileState L233+, function initState L235-260, class _BrokenSessionRow L261+, class _SessionTile L288+, function _showActions L362-456, function _showChildren L457-516
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/settings_page.dart  (736 lines)
- Defines (read with exact line ranges): class SettingsPage L15+, function createState L19-21, class _SettingsPageState L22+, function initState L24-29, function build L30-341, function _editServer L342-406, function _addMcp L407-469, class _Providers L470+, function _addKey L545-583, class _ConfigEditor L584+, class _ConfigEditorState L592+, function _pretty L597-606, function didUpdateWidget L607-612, function dispose L613-675, class _StatusRow L676+, class _ActionTile L699+
- Imports: lib/api/client.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/commands_page.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/terminal_page.dart  (275 lines)
- Defines (read with exact line ranges): class TerminalPage L8+, function createState L12-14, class _TerminalPageState L15+, function dispose L39-45, function _append L46-53, function _run L54-79, function build L80-269, function _terminalStyle L270-275
- Imports: lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/theme.dart  (990 lines)
- Defines (read with exact line ranges): class OCColors L11+, class OCTokens L115+, function of L205-213, function copyWith L214-244, function lerp L245-268, class OCTokensX L269+, class OCShadow L274+, class OCGradient L300+, class OCSpace L367+, class OCRadius L397+, class OCMotion L416+, class OCTypography L438+, function _sans L446-530, function numeric L531-543, function mono L544-551, function monoSmall L552-568, function withColor L569-572, class _TextStyleExt L573+, function buildLightTheme L579-621, class OCColorSchemeX L622+, function buildDarkTheme L635-676, function _baseTheme L677-990
- Imported by (17): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/primitives.dart, lib/ui/prompts.dart ...
- If changed, affects 17 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart ...

## lib/ui/todos_page.dart  (151 lines)
- Defines (read with exact line ranges): class TodosPage L9+, function build L13-98, class _TodoTile L99+
- Imports: lib/models/models.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/widgets.dart  (566 lines)
- Defines (read with exact line ranges): function pushScreen L11-25, function showToast L26-42, class _ToastWidget L43+, function createState L54-56, class _ToastWidgetState L57+, function dispose L65-70, function build L71-131, function showSnack L132-135, function copyToClipboard L136-146, class EmptyHint L147+, class LoadingView L206+, class ConnectionErrorView L228+, function promptText L331-369, function confirmDialog L370-404, class SectionTitle L405+, class Mono L436+, class StatusPill L463+, class InfoRow L507+, function toolIcon L545-558, function toolColor L559-566
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/ui/primitives.dart, lib/ui/theme.dart
- Imported by (12): lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart, lib/ui/todos_page.dart
- If changed, affects 13 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...
