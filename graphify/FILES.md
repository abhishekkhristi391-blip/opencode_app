# FILES - one card per file (read this instead of opening files blindly)
Format: Defines / Imports / Imported by / Calls into / If changed -> affected files / Issues / Notes

## deploy.py  (94 lines)
- Defines (read with exact line ranges): function run L21-35, function main L36-86, function shutil_which L87-94

## lib/api/client.dart  (872 lines)
- Defines (read with exact line ranges): class ApiException L12+, function toString L22-25, function _parseBytes L26-32, class OcClient L33+, function _headers L55-62, function _u L63-76, function _decode L77-117, function _send L118-145, function get L146-154, function post L155-168, function patch L169-182, function put L183-196, function delete L197-210, function close L211-216, function events L217-265, function eventsAutoReconnect L266-287, function paths L288-290, function vcs L291-292, function disposeInstance L293-295, function upgrade L296-299, function log L300-309, function config L310-311, function patchConfig L312-314, function configProviders L315-323, function providers L324-326, function providerAuthMethods L327-337, function providerAuthUrl L338-349, function setApiKey L350-357, function removeAuth L358-361, function agents L362-366, function sessions L367-371, function createSession L372-390, function session L391-393, function deleteSession L394-396, function renameSession L397-401, function childSessions L402-406, function sessionStatus L407-409, function todos L410-414, function abort L415-418, function fork L419-423 ...
- Imports: lib/models/models.dart
- Imported by (3): lib/state/store.dart, lib/ui/models_page.dart, lib/ui/settings_page.dart
- If changed, affects 15 file(s): lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart ...

## lib/api/events.dart  (212 lines)
- Defines (read with exact line ranges): class OcEvent L9+, class EventStream L43+, function start L78-83, function reconnect L84-90, function _connect L91-156, function _handleFrame L157-173, function _setConnected L174-179, function _scheduleRetry L180-198, function stop L199-212
- Imports: lib/models/models.dart
- Imported by (1): lib/state/store.dart
- If changed, affects 15 file(s): lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart ...

## lib/db/chat_db.dart  (235 lines)
- Defines (read with exact line ranges): class ChatDB L21+, function _init L42-64, function _createMessages L65-79, function _createSessions L80-93, function _enqueue L94-106, function _sortKey L107-117, function _writeRow L118-131, function upsertMessages L132-150, function deleteMessage L151-162, function loadMessages L163-183, function clearSession L184-193, function saveSessions L194-211, function saveSession L212-216, function deleteSessionRow L217-224, function loadSessions L225-235
- Imported by (1): lib/state/store.dart
- If changed, affects 15 file(s): lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart ...

## lib/l10n/strings.dart  (557 lines)
- Defines (read with exact line ranges): class S L9+, function serverOnlineVersion L111-147, function chatWelcomeSubtitle L148-173, function composerModelAgent L174-180, function toolRunning L181-181, function toolDone L182-188, function moreToolsCount L189-233, function filesCount L234-234, function messageCount L235-235, function tokensUsed L236-263, function sessionsDeleteBody L264-266, function sessionsCount L267-267, function sessionsCountOne L268-268, function forkCreated L269-304, function fileStats L305-329, function diffAddedRemoved L330-345, function tasksProgress L346-346, function tasksProgressSemantics L347-378, function useSkillPrompt L379-467, function mcpCount L468-468, function skillsCount L469-469, function toolsCount L470-470, function settingsConnectedVersion L471-552, function label L553-553, function slashCommand L554-554, function errorText L555-557
- Imported by (5): lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/home.dart, lib/ui/sessions_page.dart, lib/ui/widgets.dart
- If changed, affects 14 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...

## lib/main.dart  (72 lines)
- Defines (read with exact line ranges): function main L10-14, class OpenCodeApp L15+, function createState L19-21, class _OpenCodeAppState L22+, function initState L26-32, function dispose L33-39, function didChangeAppLifecycleState L40-55, function build L56-72
- Imports: lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/home.dart, lib/ui/theme.dart

## lib/models/models.dart  (720 lines)
- Defines (read with exact line ranges): function asMap L5-8, function asList L9-10, function asInt L11-14, function asStr L15-16, function asDouble L17-19, function asBool L20-23, class Tokens L24+, class SessionSummary L52+, class Session L65+, function toMap L124-128, class Message L129+, class ToolStatus L184+, class Part L186+, function _short L312-321, class Agent L322+, class ModelInfo L350+, class Todo L393+, class FileNode L416+, class FileDiff L438+, class CommandInfo L464+, class SkillInfo L485+, class NamedStatus L500+, class VcsInfo L523+, class ServerPaths L535+, class PermissionReq L556+, function _fmt L617-623, class QuestionOption L624+, class QuestionItem L631+, class QuestionReq L654+, function fmtBytes L679-684, function fmtTime L685-690, function fmtAge L691-700, function fmtDuration L701-708, function baseName L709-713, function dirName L714-720
- Imported by (14): lib/api/client.dart, lib/api/events.dart, lib/state/store.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart ...
- If changed, affects 19 file(s): lib/api/client.dart, lib/api/events.dart, lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart ...

## lib/state/store.dart  (1626 lines)
- Defines (read with exact line ranges): class ChatMessage L15+, class PendingAttachment L31+, class OcStore L46+, function setShowTokensInChat L93-120, function _scheduleNotify L121-129, function _debouncedTodos L130-142, function _dbRow L143-152, function _isCacheable L153-165, function _mergeHistory L166-184, function _cachedHistory L185-210, function _scheduleFlush L211-228, function _flushHistory L229-244, function _persistHistory L245-251, function _ensureStoragePermission L252-271, function boot L272-287, function _persist L288-304, function setServer L305-312, function connect L313-347, function _startStream L348-368, function _resyncMessages L369-394, function refreshServerInfo L395-404, function refreshCatalog L405-436, function setModel L437-443, function setAgent L444-449, function toggleTool L450-466, function refreshSessions L467-493, function _persistSessions L494-504, function _restoreSessionsFromCache L505-522, function newSession L523-540, function openSession L541-597, function _safeSession L598-606, function renameSession L607-615, function deleteSession L616-632, function forkSession L633-643, function shareSession L644-653, function unshareSession L654-662, function abortSession L663-680, function refreshTodos L681-691, function refreshDiff L692-715, function _prependHistory L716-729 ...
- Imports: lib/api/client.dart, lib/api/events.dart, lib/db/chat_db.dart, lib/models/models.dart
- Imported by (10): lib/main.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart
- If changed, affects 14 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/prompts.dart ...

## lib/ui/about_page.dart  (119 lines)
- Defines (read with exact line ranges): class AboutPage L10+, function build L14-119
- Imports: lib/l10n/strings.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/app_scope.dart  (22 lines)
- Defines (read with exact line ranges): class AppScope L6+, function of L10-16, function read L17-22
- Imports: lib/state/store.dart
- Imported by (13): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart, lib/ui/terminal_page.dart ...
- If changed, affects 13 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart ...

## lib/ui/chat.dart  (2141 lines)
- Defines (read with exact line ranges): class ChatPage L21+, function createState L25-32, class _ChatPageState L33+, function initState L70-82, function dispose L83-95, function _onStoreChange L96-105, function _onScroll L106-114, function _handleNotification L115-137, function _setFollow L138-147, function _queueAutoScroll L148-161, function _runAutoScroll L162-172, function _jumpToLatest L173-190, function _loadOlderMessages L191-213, function _syncFollow L214-231, function build L232-259, function _sendSuggestion L260-268, function _send L269-307, class _ErrorBarWidget L308+, class _BusyBarWidget L328+, class _ChatMessages L350+, class _JumpToLatest L431+, class _LoadOlderButton L478+, class _ErrorBar L504+, class _BusyBar L542+, class _Welcome L555+, class _SuggestionCard L608+, class _MessageTile L658+, class _MessageTileState L673+, function didChangeDependencies L680-684, function _signature L685-706, function _openMenu L707-710, function _buildContent L711-756, function _userBubble L757-802, function _assistantBlock L803-844, class _ReplyMeta L845+, class _ReplyActions L871+, class _ActionBtn L906+, function showMessageMenu L949-1023, class _SheetRow L1024+, class _IncomingFileChip L1061+ ...
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

## lib/ui/files_page.dart  (687 lines)
- Defines (read with exact line ranges): class FilesPage L12+, function createState L16-18, class _FilesPageState L19+, function initState L29-34, function dispose L35-39, function _load L40-77, function build L78-233, function _open L234-241, function _menu L242-334, function _q L335-337, function _pillBorder L338-344, class ChangedFilesPage L345+, class _FileTile L395+, function _icon L445-472, class FileEditorPage L473+, class _FileEditorPageState L481+, function _save L527-687
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

## lib/ui/parts.dart  (751 lines)
- Defines (read with exact line ranges): class ToolTimeline L21+, function createState L26-28, class _ToolTimelineState L29+, function build L34-70, function _buildStep L71-210, class PartTile L211+, function _firstLine L312-319, class _Collapsible L320+, class _CollapsibleState L338+, class ToolTile L413+, class _InputBlock L463+, function _pretty L485-493, class _OutputBlock L494+, class _OutputBlockState L503+, class _FilePart L575+, class _AgentPart L619+, class _RetryPart L641+, class _UnknownPart L673+, class DiffText L705+
- Imports: lib/models/models.dart, lib/ui/line_icons.dart, lib/ui/markdown.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
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

## lib/ui/settings_page.dart  (734 lines)
- Defines (read with exact line ranges): class SettingsPage L14+, function createState L18-20, class _SettingsPageState L21+, function initState L23-28, function build L29-340, function _editServer L341-405, function _addMcp L406-468, class _Providers L469+, function _addKey L544-582, class _ConfigEditor L583+, class _ConfigEditorState L591+, function _pretty L596-604, function didUpdateWidget L605-610, function dispose L611-673, class _StatusRow L674+, class _ActionTile L697+
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
