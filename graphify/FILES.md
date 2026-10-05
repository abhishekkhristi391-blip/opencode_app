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

## lib/l10n/strings.dart  (1017 lines)
- Defines (read with exact line ranges): class S L9+, function serverOnlineVersion L111-190, function composerModelAgent L191-196, function toolRunning L197-197, function toolDone L198-204, function moreToolsCount L205-250, function filesCount L251-251, function messageCount L252-252, function tokensUsed L253-280, function sessionsDeleteBody L281-299, function historyFiles L300-307, function cmdArgs L308-308, function cmdUseSkill L309-309, function cmdUseLabel L310-310, function partsAgent L311-327, function diffAppliesTo L328-344, function filesDeleteBody L345-348, function filesNameLabel L349-350, function filesEmptyName L351-352, function filesNameHint L353-369, function setPermExternalTitle L370-371, function setPermExternalBody L372-375, function setPassword L376-386, function filesExists L387-387, function filesDeleteFailed L388-388, function filesFolderFailed L389-391, function added L392-414, function netTimeout L415-415, function netUnreachable L416-421, function permSuggestingRules L422-431, function filesChangedCount L432-457, function modelsContext L458-458, function modelsSelected L459-463, function setMcpLabel L464-483, function partsThoughtFor L484-485, function partsThinkingLines L486-490, function composerWorking L491-492, function composerQueued L493-495, function sessionsCount L496-496, function sessionsCountOne L497-497 ...
- Imported by (17): lib/api/client.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...
- If changed, affects 19 file(s): lib/api/client.dart, lib/main.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart ...

## lib/main.dart  (74 lines)
- Defines (read with exact line ranges): function main L8-12, class OpenCodeApp L13+, function createState L17-19, class _OpenCodeAppState L20+, function initState L24-30, function dispose L31-37, function didChangeAppLifecycleState L38-57, function build L58-74
- Imports: lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/home.dart, lib/ui/theme.dart

## lib/models/models.dart  (743 lines)
- Defines (read with exact line ranges): function asMap L5-8, function asList L9-10, function asInt L11-14, function asStr L15-16, function asDouble L17-19, function asBool L20-23, class Tokens L24+, class SessionSummary L52+, class Session L65+, function toMap L124-128, class Message L129+, class ToolStatus L207+, class Part L209+, function _short L335-344, class Agent L345+, class ModelInfo L373+, class Todo L416+, class FileNode L439+, class FileDiff L461+, class CommandInfo L487+, class SkillInfo L508+, class NamedStatus L523+, class VcsInfo L546+, class ServerPaths L558+, class PermissionReq L579+, function _fmt L640-646, class QuestionOption L647+, class QuestionItem L654+, class QuestionReq L677+, function fmtBytes L702-707, function fmtTime L708-713, function fmtAge L714-723, function fmtDuration L724-731, function baseName L732-736, function dirName L737-743
- Imported by (15): lib/api/client.dart, lib/api/events.dart, lib/state/store.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart ...
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

## lib/ui/chat.dart  (3025 lines)
- Defines (read with exact line ranges): class ChatPage L22+, function createState L26-33, class _ChatPageState L34+, function initState L81-97, function dispose L98-109, function _onStoreChange L110-122, function _chatMessageCount L123-133, function _onScroll L134-145, function _bumpUnread L146-153, function _handleNotification L154-176, function _setFollow L177-186, function _queueAutoScroll L187-200, function _runAutoScroll L201-211, function _jumpToLatest L212-230, function _loadOlderMessages L231-253, function _syncFollow L254-288, function build L289-320, function _sendSuggestion L321-329, function _send L330-369, class _ErrorBarWidget L370+, class _BusyBarWidget L390+, class _ChatMessages L412+, function _buildList L445-538, class _JumpToLatest L539+, class _LoadOlderButton L607+, class _ErrorBar L633+, class _BusyBar L671+, class _Welcome L686+, class _ModelModeChips L784+, class OutlinedChip L819+, class _ProjectBar L909+, function _showDetails L977-1029, class SuggestionCard L1030+, class _SuggestionCardState L1046+, class _MessageTile L1131+, class _MessageTileState L1146+, function didChangeDependencies L1153-1157, function _signature L1158-1179, function _openMenu L1180-1183, function _buildContent L1184-1240 ...
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/line_icons.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (4): lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart
- If changed, affects 6 file(s): lib/main.dart, lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/commands_page.dart  (223 lines)
- Defines (read with exact line ranges): class CommandsPage L14+, function build L18-45, class _CommandTile L46+, class SkillsSection L151+
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/markdown.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (2): lib/ui/home.dart, lib/ui/settings_page.dart
- If changed, affects 3 file(s): lib/main.dart, lib/ui/home.dart, lib/ui/settings_page.dart

## lib/ui/diff_page.dart  (484 lines)
- Defines (read with exact line ranges): class DiffPage L12+, function createState L16-18, class _DiffPageState L19+, function initState L29-33, function _load L34-80, function build L81-205, class _SessionDiffTile L206+, function _unifiedPreview L340-355, function _split L356-359, function _diffOps L360-405, function _toGitPatch L406-408, class _GitDiffView L409+
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/parts.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/files_page.dart  (806 lines)
- Defines (read with exact line ranges): class FilesPage L11+, function createState L15-17, class FilesPageState L18+, function initState L28-33, function reload L34-37, function promptCreate L38-40, function dispose L41-48, function _normDir L49-61, function _validName L62-72, function _createMenu L73-102, function _newFile L103-133, function _newFolder L134-149, function _load L150-187, function build L188-353, function _open L354-361, function _menu L362-465, function _q L466-470, function _pillBorder L471-478, class ChangedFilesPage L479+, class _FileTile L529+, function _icon L579-606, class FileEditorPage L607+, class _FileEditorPageState L615+, function _save L661-806
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/home.dart  (1596 lines)
- Defines (read with exact line ranges): class _Tab L24+, class HomeShell L37+, function createState L41-43, class HomeShellState L44+, function goTo L67-70, function _navigate L71-75, function _pushAndClose L76-81, function _worktree L82-87, function build L88-128, function _headerActions L129-206, function _focusHistorySearch L207-209, function _reloadFiles L210-211, function _createFileOrFolder L212-214, function _clearTerminal L215-217, function _newTerminalSession L218-222, function _showDrawer L223-271, function _showAvatarMenu L272-294, function _hostLabel L295-302, function _body L303-326, function _showMoreSheet L327-443, function _pickAgent L444-487, function _pickTools L488-551, function _openSessionScreen L552-576, function _renameSession L577-594, class _AvatarButton L595+, class _DrawerBadge L638+, class _Drawer L673+, class _DrawerNavRow L856+, class _DrawerRecentRow L934+, class _DrawerFooter L1021+, class _DrawerIconButton L1171+, class _ServerMenu L1224+, class _ServerMenuHeader L1322+, class _MenuRow L1434+, class _SheetOption L1513+, class _SheetGroup L1574+
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/about_page.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/line_icons.dart, lib/ui/models_page.dart, lib/ui/primitives.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart
- Imported by (1): lib/main.dart
- If changed, affects 1 file(s): lib/main.dart

## lib/ui/line_icons.dart  (1144 lines)
- Defines (read with exact line ranges): class LI L22+, class LIcon L170+, function build L185-207, class LIconButton L208+, class LLinePainter L271+, function paint L285-305, function _path L306-311, function _draw L312-1140, function shouldRepaint L1141-1144
- Imports: lib/ui/theme.dart
- Imported by (5): lib/ui/chat.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/parts.dart, lib/ui/widgets.dart
- If changed, affects 15 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart ...

## lib/ui/markdown.dart  (599 lines)
- Defines (read with exact line ranges): class Markdown L20+, function build L34-51, function _buildBlock L52-104, function _paragraph L105-114, function _listBlock L115-148, function _bulletMarker L149-153, function _table L154-211, function _rich L212-234, function _firstFrom L235-239, function _inlineSpans L240-283, function _makeSpan L284-316, function _linkSpan L317-339, function _codeStyle L340-359, class _Kind L360+, class _Block L362+, function _parseCached L383-394, function _parse L395-400, function flushPara L401-513, class _CodeBlock L514+
- Imports: lib/l10n/strings.dart, lib/ui/line_icons.dart, lib/ui/theme.dart
- Imported by (3): lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/parts.dart
- If changed, affects 9 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/models_page.dart  (426 lines)
- Defines (read with exact line ranges): class ModelsPage L13+, function createState L17-19, class _ModelsPageState L20+, function initState L26-33, function dispose L34-39, function build L40-244, class _AgentDropdown L245+, class _ProviderBlock L278+, class _ModelTag L408+
- Imports: lib/api/client.dart, lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/chat.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (2): lib/ui/chat.dart, lib/ui/home.dart
- If changed, affects 6 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/home.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/parts.dart  (989 lines)
- Defines (read with exact line ranges): class ToolTimeline L26+, function createState L31-33, class _ToolTimelineState L34+, function build L39-90, function _buildStep L91-230, class PartTile L231+, function _firstLine L332-339, class _Collapsible L340+, class _CollapsibleState L358+, class ToolTile L458+, class _InputBlock L508+, function _pretty L530-540, function _isExternalPermissionError L541-576, class _OutputBlock L577+, class _OutputBlockState L586+, class _FilePart L726+, class _AgentPart L770+, class _RetryPart L792+, class _UnknownPart L824+, class DiffText L856+, class ThinkingGroup L908+
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/line_icons.dart, lib/ui/markdown.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (2): lib/ui/chat.dart, lib/ui/diff_page.dart
- If changed, affects 8 file(s): lib/main.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart

## lib/ui/primitives.dart  (1556 lines)
- Defines (read with exact line ranges): class OCAccent L22+, function at L75-81, class OCButtonVariant L82+, class OCButton L110+, function createState L137-139, class _OCButtonState L140+, function build L283-355, class OCCardVariant L356+, class OCCard L368+, class OCInnerCell L420+, class OCIconTile L473+, class OCStatus L547+, class OCAvatar L552+, class OCAvatarStack L637+, class OCToggle L710+, class OCSegmentedControl L783+, class OCSegment L821+, class _SegmentItem L828+, class OCProgressBar L900+, class OCProgressRing L952+, class _RingPainter L1017+, function paint L1031-1058, function shouldRepaint L1059-1072, class OCChip L1073+, class OCListRow L1158+, class OCBreadcrumbs L1284+, class OCFilterButton L1394+, class OCSkeleton L1454+, class _OCSkeletonState L1470+, function dispose L1478-1501, class OCSkeletonList L1502+
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

## lib/ui/settings_page.dart  (818 lines)
- Defines (read with exact line ranges): class SettingsPage L16+, function createState L20-22, class _SettingsPageState L23+, function initState L25-30, function build L31-375, function _editServer L376-438, function _addMcp L439-512, class _Group L513+, class _GroupDivider L549+, class _Providers L558+, function _addKey L630-668, class _ConfigEditor L669+, class _ConfigEditorState L677+, function _pretty L682-691, function didUpdateWidget L692-697, function dispose L698-757, class _StatusRow L758+, class _ActionTile L781+
- Imports: lib/api/client.dart, lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/app_scope.dart, lib/ui/commands_page.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/terminal_page.dart  (304 lines)
- Defines (read with exact line ranges): class TerminalPage L9+, function createState L13-15, class TerminalPageState L16+, function clear L42-48, function newSession L49-56, function dispose L57-63, function _append L64-71, function _run L72-97, function build L98-300, function _terminalStyle L301-304
- Imports: lib/l10n/strings.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/theme.dart  (1253 lines)
- Defines (read with exact line ranges): class OCColors L17+, class OCTokens L237+, function of L377-380, function copyWith L381-449, function lerp L450-498, class OCShadow L499+, class OCGradient L542+, class OCTokensX L573+, class OCSpace L578+, class OCRadius L633+, class OCMotion L686+, class OCTypography L723+, function _wght L752-756, function _sans L757-780, function _serif L781-798, function _mono L799-899, function numeric L900-912, function mono L913-924, function monoSmall L925-927, function monoLarge L928-931, function code L932-935, function codeBlock L936-960, class _TextStyleExt L961+, function withColor L962-973, function buildAppTheme L974-975, function _buildTheme L976-1226, function _fieldBorder L1227-1232, function _textTheme L1233-1253
- Imported by (18): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/line_icons.dart, lib/ui/markdown.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/primitives.dart ...
- If changed, affects 18 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/line_icons.dart, lib/ui/markdown.dart, lib/ui/models_page.dart ...

## lib/ui/todos_page.dart  (152 lines)
- Defines (read with exact line ranges): class TodosPage L10+, function build L14-99, class _TodoTile L100+
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/ui/app_scope.dart, lib/ui/primitives.dart, lib/ui/theme.dart, lib/ui/widgets.dart
- Imported by (1): lib/ui/home.dart
- If changed, affects 2 file(s): lib/main.dart, lib/ui/home.dart

## lib/ui/widgets.dart  (970 lines)
- Defines (read with exact line ranges): function pushScreen L13-27, function showToast L28-44, class _ToastWidget L45+, function createState L56-58, class _ToastWidgetState L59+, function dispose L67-72, function build L73-133, function showSnack L134-139, function showUndoSnack L140-150, function copyToClipboard L151-161, class EmptyHint L162+, class LoadingView L221+, class ConnectionErrorView L243+, function promptText L346-384, function confirmDialog L385-419, class SectionTitle L420+, class Mono L451+, function ocReduceMotion L484-490, class OcLinkState L491+, class StatusPill L513+, class _StatusPillState L538+, function initState L546-551, function didUpdateWidget L552-556, function _sync L557-676, function ocLinkState L677-688, class HeaderAction L689+, class AppHeader L718+, class HeaderButton L825+, class CountBadge L878+, class InfoRow L911+, function toolIcon L949-962, function toolColor L963-970
- Imports: lib/l10n/strings.dart, lib/models/models.dart, lib/state/store.dart, lib/ui/line_icons.dart, lib/ui/primitives.dart, lib/ui/theme.dart
- Imported by (12): lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart, lib/ui/sessions_page.dart, lib/ui/settings_page.dart, lib/ui/todos_page.dart
- If changed, affects 13 file(s): lib/main.dart, lib/ui/about_page.dart, lib/ui/chat.dart, lib/ui/commands_page.dart, lib/ui/diff_page.dart, lib/ui/files_page.dart, lib/ui/home.dart, lib/ui/models_page.dart, lib/ui/parts.dart, lib/ui/prompts.dart ...
