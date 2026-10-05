# FILES - one card per file (read this instead of opening files blindly)
Format: Defines / Imports / Imported by / Calls into / If changed -> affected files / Issues / Notes

## deploy.py  (94 lines)
- Defines (read with exact line ranges): function run L21-35, function main L36-86, function shutil_which L87-94

## lib/api/client.dart  (844 lines)
- Defines (read with exact line ranges): class ApiException L13+, function toString L23-26, function _parseBytes L27-33, class OcClient L34+, function _headers L56-63, function _u L64-77, function _decode L78-120, function _sendOnce L121-168, function _send L169-184, function get L185-194, function post L195-208, function patch L209-222, function put L223-236, function delete L237-250, function close L251-259, function paths L260-262, function vcs L263-264, function disposeInstance L265-267, function upgrade L268-271, function log L272-281, function config L282-283, function patchConfig L284-286, function configProviders L287-295, function providers L296-298, function providerAuthMethods L299-309, function providerAuthUrl L310-321, function setApiKey L322-329, function removeAuth L330-333, function agents L334-338, function sessions L339-343, function createSession L344-362, function session L363-365, function deleteSession L366-368, function renameSession L369-373, function childSessions L374-378, function sessionStatus L379-381, function todos L382-386, function abort L387-390, function fork L391-395, function share L396-401 ...
- Imports: lib/l10n/strings.dart, lib/models/models.dart
- Imported by (3): lib/state/store.dart, lib/ui/models_page.dart, lib/ui/settings_page.dart
- If changed, affects 17 file(s): lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart ...

## lib/api/events.dart  (429 lines)
- Defines (read with exact line ranges): class OcEvent L12+, class EventStream L48+, function start L129-135, function reconnect L136-147, function _connect L148-248, function _checkLiveness L249-260, function _probeLiveness L261-325, function _handleFrame L326-342, function _setConnected L343-352, function _markDown L353-361, function _scheduleRetry L362-388, function stop L389-400, function shutdown L401-409, function _teardown L410-429
- Imports: lib/models/models.dart
- Imported by (1): lib/state/store.dart
- If changed, affects 17 file(s): lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart ...

## lib/db/chat_db.dart  (235 lines)
- Defines (read with exact line ranges): class ChatDB L21+, function _init L42-64, function _createMessages L65-79, function _createSessions L80-93, function _enqueue L94-106, function _sortKey L107-117, function _writeRow L118-131, function upsertMessages L132-150, function deleteMessage L151-162, function loadMessages L163-183, function clearSession L184-193, function saveSessions L194-211, function saveSession L212-216, function deleteSessionRow L217-224, function loadSessions L225-235
- Imported by (1): lib/state/store.dart
- If changed, affects 17 file(s): lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart ...

## lib/l10n/strings.dart  (944 lines)
- Defines (read with exact line ranges): class S L9+, function serverOnlineVersion L111-190, function composerModelAgent L191-197, function toolRunning L198-198, function toolDone L199-205, function moreToolsCount L206-251, function filesCount L252-252, function messageCount L253-253, function tokensUsed L254-281, function sessionsDeleteBody L282-300, function historyFiles L301-308, function cmdArgs L309-309, function cmdUseSkill L310-310, function cmdUseLabel L311-311, function partsAgent L312-328, function diffAppliesTo L329-345, function filesDeleteBody L346-349, function filesNameLabel L350-351, function filesEmptyName L352-353, function filesNameHint L354-370, function setPermExternalTitle L371-372, function setPermExternalBody L373-376, function setPassword L377-387, function filesExists L388-388, function filesDeleteFailed L389-389, function filesFolderFailed L390-392, function added L393-415, function netTimeout L416-416, function netUnreachable L417-422, function permSuggestingRules L423-432, function filesChangedCount L433-458, function modelsContext L459-459, function modelsSelected L460-464, function setMcpLabel L465-484, function partsThoughtFor L485-486, function partsThinkingLines L487-491, function composerWorking L492-493, function composerQueued L494-496, function sessionsCount L497-497, function sessionsCountOne L498-498 ...
- Imported by (17): lib/api/client.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...
- If changed, affects 19 file(s): lib/api/client.dart, lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart ...

## lib/main.dart  (74 lines)
- Defines (read with exact line ranges): function main L8-12, class OpenCodeApp L13+, function createState L17-19, class _OpenCodeAppState L20+, function initState L24-30, function dispose L31-37, function didChangeAppLifecycleState L38-57, function build L58-74
- Imports: lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/home.dart, lib/ui/theme.dart

## lib/models/models.dart  (743 lines)
- Defines (read with exact line ranges): function asMap L5-8, function asList L9-10, function asInt L11-14, function asStr L15-16, function asDouble L17-19, function asBool L20-23, class Tokens L24+, class SessionSummary L52+, class Session L65+, function toMap L124-128, class Message L129+, class ToolStatus L207+, class Part L209+, function _short L335-344, class Agent L345+, class ModelInfo L373+, class Todo L416+, class FileNode L439+, class FileDiff L461+, class CommandInfo L487+, class SkillInfo L508+, class NamedStatus L523+, class VcsInfo L546+, class ServerPaths L558+, class PermissionReq L579+, function _fmt L640-646, class QuestionOption L647+, class QuestionItem L654+, class QuestionReq L677+, function fmtBytes L702-707, function fmtTime L708-713, function fmtAge L714-723, function fmtDuration L724-731, function baseName L732-736, function dirName L737-743
- Imported by (14): lib/api/client.dart, lib/api/events.dart, lib/state/store.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart ...
- If changed, affects 19 file(s): lib/api/client.dart, lib/api/events.dart, lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart ...
- WHY: the raw message needs this before the UI can show anything. :189

## lib/state/store.dart  (2166 lines)
- Defines (read with exact line ranges): class ChatMessage L14+, class PendingAttachment L46+, class MessageListSignal L68+, function notify L73-75, class OcStore L76+, function setShowTokensInChat L145-182, function _scheduleNotify L183-197, function _scheduleMessageNotify L198-210, function _debouncedTodos L211-223, function _dbRow L224-234, function _isCacheable L235-249, function _mergeHistory L250-275, function _messageText L276-299, function _stripEchoedOptimistic L300-331, function _cachedHistory L332-357, function _scheduleFlush L358-375, function _flushHistory L376-391, function _persistHistory L392-406, function boot L407-422, function _persist L423-439, function setServer L440-447, function connect L448-497, function _offlineMessage L498-510, function _verifyReachability L511-565, function _startStream L566-587, function _onStreamStatus L588-617, function _resyncMessages L618-652, function refreshServerInfo L653-662, function refreshCatalog L663-694, function setModel L695-701, function setAgent L702-707, function toggleTool L708-724, function refreshSessions L725-751, function _persistSessions L752-762, function _restoreSessionsFromCache L763-781, function newSession L782-799, function openSession L800-858, function _safeSession L859-867, function renameSession L868-876, function deleteSession L877-894 ...
- Imports: lib/api/client.dart, lib/api/events.dart, lib/db/chat_db.dart, lib/l10n/strings.dart, lib/models/models.dart
- Imported by (12): lib/main.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart, lib/ui/widgets.dart
- If changed, affects 16 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart ...
- NOTE: there is deliberately no storage-permission gate here. File writes go :399

## lib/ui/about_page.dart  (119 lines)
- Defines (read with exact line ranges): class AboutPage L10+, function build L14-119
- Imports: lib/l10n/strings.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/app_scope.dart  (23 lines)
- Defines (read with exact line ranges): class AppScope L6+, function of L10-16, function read L17-23
- Imports: lib/state/store.dart
- Imported by (14): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart ...
- If changed, affects 14 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...

## lib/ui/chat.dart  (2983 lines)
- Defines (read with exact line ranges): class ChatPage L22+, function createState L26-33, class _ChatPageState L34+, function initState L81-97, function dispose L98-109, function _onStoreChange L110-122, function _chatMessageCount L123-133, function _onScroll L134-145, function _bumpUnread L146-153, function _handleNotification L154-176, function _setFollow L177-186, function _queueAutoScroll L187-200, function _runAutoScroll L201-211, function _jumpToLatest L212-230, function _loadOlderMessages L231-253, function _syncFollow L254-288, function build L289-320, function _sendSuggestion L321-329, function _send L330-369, class _ErrorBarWidget L370+, class _BusyBarWidget L390+, class _ChatMessages L412+, function _buildList L445-538, class _JumpToLatest L539+, class _LoadOlderButton L607+, class _ErrorBar L633+, class _BusyBar L671+, class _Welcome L686+, class _ModelModeChips L784+, class OutlinedChip L819+, class _ProjectBar L909+, function _showDetails L977-1029, class SuggestionCard L1030+, class _SuggestionCardState L1046+, class _MessageTile L1131+, class _MessageTileState L1146+, function didChangeDependencies L1153-1157, function _signature L1158-1179, function _openMenu L1180-1183, function _buildContent L1184-1240 ...
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/line_icons.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (4): lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart
- If changed, affects 6 file(s): lib/main.dart, lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/commands_page.dart  (223 lines)
- Defines (read with exact line ranges): class CommandsPage L14+, function build L18-45, class _CommandTile L46+, class SkillsSection L151+
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/markdown.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (2): lib/ui/home.dart, lib/ui/settings_page.dart
- If changed, affects 3 file(s): lib/main.dart, lib/ui/home.dart, lib/ui/settings_page.dart

## lib/ui/diff_page.dart  (482 lines)
- Defines (read with exact line ranges): class DiffPage L12+, function createState L16-18, class _DiffPageState L19+, function initState L29-33, function _load L34-80, function build L81-205, class _SessionDiffTile L206+, function _unifiedPreview L338-353, function _split L354-357, function _diffOps L358-403, function _toGitPatch L404-406, class _GitDiffView L407+
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/parts.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/files_page.dart  (806 lines)
- Defines (read with exact line ranges): class FilesPage L11+, function createState L15-17, class FilesPageState L18+, function initState L28-33, function reload L34-37, function promptCreate L38-40, function dispose L41-48, function _normDir L49-61, function _validName L62-72, function _createMenu L73-102, function _newFile L103-133, function _newFolder L134-149, function _load L150-187, function build L188-353, function _open L354-361, function _menu L362-465, function _q L466-470, function _pillBorder L471-478, class ChangedFilesPage L479+, class _FileTile L529+, function _icon L579-606, class FileEditorPage L607+, class _FileEditorPageState L615+, function _save L661-806
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/home.dart  (735 lines)
- Defines (read with exact line ranges): class _Tab L25+, class HomeShell L33+, function createState L37-39, class HomeShellState L40+, function goTo L67-69, function build L70-117, function _headerActions L118-198, function _focusHistorySearch L199-201, function _reloadFiles L202-203, function _createFileOrFolder L204-206, function _clearTerminal L207-209, function _newTerminalSession L210-212, function _body L213-236, function _showMoreSheet L237-353, function _pickAgent L354-397, function _pickTools L398-461, function _openSessionScreen L462-486, function _renameSession L487-502, class BottomNav L503+, class _NavItem L548+, class _SheetOption L652+, class _SheetGroup L713+
- Imports: lib/l10n/strings.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/line_icons.dart, lib/ui/models_page.dart, lib/ui/primitives.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart, lib/ui/terminal_page.dart
- Imported by (1): lib/main.dart
- If changed, affects 1 file(s): lib/main.dart

## lib/ui/line_icons.dart  (648 lines)
- Defines (read with exact line ranges): class LI L17+, class LIcon L99+, function build L114-135, class LIconButton L136+, class LLinePainter L189+, function paint L203-223, function _path L224-229, function _draw L230-644, function shouldRepaint L645-648
- Imported by (5): lib/ui/chat.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/parts.dart, lib/ui/widgets.dart
- If changed, affects 15 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart ...

## lib/ui/markdown.dart  (589 lines)
- Defines (read with exact line ranges): class Markdown L20+, function build L34-51, function _buildBlock L52-104, function _paragraph L105-114, function _listBlock L115-148, function _bulletMarker L149-153, function _table L154-211, function _rich L212-234, function _firstFrom L235-239, function _inlineSpans L240-283, function _makeSpan L284-316, function _linkSpan L317-339, function _codeStyle L340-356, class _Kind L357+, class _Block L359+, function _parseCached L380-391, function _parse L392-397, function flushPara L398-510, class _CodeBlock L511+
- Imports: lib/l10n/strings.dart, lib/ui/line_icons.dart, lib/ui/theme.dart
- Imported by (3): lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/parts.dart
- If changed, affects 9 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/models_page.dart  (426 lines)
- Defines (read with exact line ranges): class ModelsPage L13+, function createState L17-19, class _ModelsPageState L20+, function initState L26-33, function dispose L34-39, function build L40-244, class _AgentDropdown L245+, class _ProviderBlock L278+, class _ModelTag L408+
- Imports: lib/api/client.dart, lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (2): lib/ui/chat.dart, lib/ui/home.dart
- If changed, affects 6 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/parts.dart  (964 lines)
- Defines (read with exact line ranges): class ToolTimeline L26+, function createState L31-33, class _ToolTimelineState L34+, function build L39-90, function _buildStep L91-230, class PartTile L231+, function _firstLine L332-339, class _Collapsible L340+, class _CollapsibleState L358+, class ToolTile L433+, class _InputBlock L483+, function _pretty L505-515, function _isExternalPermissionError L516-551, class _OutputBlock L552+, class _OutputBlockState L561+, class _FilePart L701+, class _AgentPart L745+, class _RetryPart L767+, class _UnknownPart L799+, class DiffText L831+, class ThinkingGroup L883+
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/line_icons.dart, lib/ui/markdown.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (2): lib/ui/chat.dart, lib/ui/diff_page.dart
- If changed, affects 8 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/primitives.dart  (1544 lines)
- Defines (read with exact line ranges): class OCAccent L20+, function at L66-72, class OCButtonVariant L73+, class OCButton L98+, function createState L125-127, class _OCButtonState L128+, function build L271-346, class OCCardVariant L347+, class OCCard L359+, class OCInnerCell L411+, class OCIconTile L464+, class OCStatus L538+, class OCAvatar L543+, class OCAvatarStack L626+, class OCToggle L699+, class OCSegmentedControl L772+, class OCSegment L810+, class _SegmentItem L817+, class OCProgressBar L889+, class OCProgressRing L941+, class _RingPainter L1005+, function paint L1019-1046, function shouldRepaint L1047-1060, class OCChip L1061+, class OCListRow L1147+, class OCBreadcrumbs L1272+, class OCFilterButton L1382+, class OCSkeleton L1442+, class _OCSkeletonState L1458+, function dispose L1466-1489, class OCSkeletonList L1490+
- Imports: lib/ui/theme.dart
- Imported by (14): lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart, lib/ui/terminal_page.dart ...
- If changed, affects 15 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...

## lib/ui/prompts.dart  (363 lines)
- Defines (read with exact line ranges): class PromptOverlay L13+, function build L17-40, class _PermissionCard L41+, class _QuestionCard L141+, function createState L146-148, class _QuestionCardState L149+, function dispose L156-162, function _toggle L163-250, function _question L251-332, class ShareCard L333+
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/sessions_page.dart  (772 lines)
- Defines (read with exact line ranges): class SessionsPage L13+, function createState L17-19, class SessionsPageState L20+, function focusSearch L32-33, function clearSearch L34-40, function dispose L41-49, function build L50-72, class _SessionsHeader L73+, function visibleSessions L177-197, class _SessionsList L198+, class _SessionsListState L207+, function _pushTileErrorGuard L308-319, function _popTileErrorGuard L320-337, class _GuardedSessionTile L338+, class _GuardedSessionTileState L347+, function initState L349-374, class _BrokenSessionRow L375+, class _SessionTile L402+, function _showActions L518-612, function _showChildren L613-676, class _GroupedSessionList L677+, function _bucket L716-727, class _Row L728+, class _GroupHeaderDelegate L738+, function shouldRebuild L770-772
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/settings_page.dart  (724 lines)
- Defines (read with exact line ranges): class SettingsPage L16+, function createState L20-22, class _SettingsPageState L23+, function initState L25-30, function build L31-337, function _editServer L338-400, function _addMcp L401-463, class _Providers L464+, function _addKey L536-574, class _ConfigEditor L575+, class _ConfigEditorState L583+, function _pretty L588-597, function didUpdateWidget L598-603, function dispose L604-663, class _StatusRow L664+, class _ActionTile L687+
- Imports: lib/api/client.dart, lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/commands_page.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/terminal_page.dart  (293 lines)
- Defines (read with exact line ranges): class TerminalPage L9+, function createState L13-15, class TerminalPageState L16+, function clear L42-48, function newSession L49-56, function dispose L57-63, function _append L64-71, function _run L72-97, function build L98-289, function _terminalStyle L290-293
- Imports: lib/l10n/strings.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/theme.dart  (1251 lines)
- Defines (read with exact line ranges): class OCColors L17+, class OCTokens L232+, function of L372-375, function copyWith L376-444, function lerp L445-493, class OCShadow L494+, class OCGradient L537+, class OCTokensX L568+, class OCSpace L573+, class OCRadius L631+, class OCMotion L684+, class OCTypography L721+, function _wght L750-754, function _sans L755-778, function _serif L779-796, function _mono L797-897, function numeric L898-910, function mono L911-922, function monoSmall L923-925, function monoLarge L926-929, function code L930-933, function codeBlock L934-958, class _TextStyleExt L959+, function withColor L960-971, function buildAppTheme L972-973, function _buildTheme L974-1224, function _fieldBorder L1225-1230, function _textTheme L1231-1251
- Imported by (17): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/primitives.dart, lib/ui/prompts.dart ...
- If changed, affects 17 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart ...

## lib/ui/todos_page.dart  (152 lines)
- Defines (read with exact line ranges): class TodosPage L10+, function build L14-99, class _TodoTile L100+
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/widgets.dart  (917 lines)
- Defines (read with exact line ranges): function pushScreen L13-27, function showToast L28-44, class _ToastWidget L45+, function createState L56-58, class _ToastWidgetState L59+, function dispose L67-72, function build L73-133, function showSnack L134-139, function showUndoSnack L140-150, function copyToClipboard L151-161, class EmptyHint L162+, class LoadingView L221+, class ConnectionErrorView L243+, function promptText L346-384, function confirmDialog L385-419, class SectionTitle L420+, class Mono L451+, function ocReduceMotion L484-490, class OcLinkState L491+, class StatusPill L508+, class _StatusPillState L533+, function initState L541-546, function didUpdateWidget L547-551, function _sync L552-668, function ocLinkState L669-680, class HeaderAction L681+, class AppHeader L706+, class HeaderButton L772+, class CountBadge L825+, class InfoRow L858+, function toolIcon L896-909, function toolColor L910-917
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/line_icons.dart, lib/ui/primitives.dart, lib/ui/theme.dart
- Imported by (12): lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart, lib/ui/todos_page.dart
- If changed, affects 13 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...
