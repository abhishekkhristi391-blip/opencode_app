# CODEMAP

Flutter/Android client (`opencode_chat`) for the opencode server.
Node kinds: `file` · `class` · `fn` · `route` · `store` · `config` · `ext`.
Edge tags: **EXTRACTED** (literal import/call/route in code) · **INFERRED** (0.4–0.9) · **AMBIGUOUS** (0.1–0.3).

## Communities

### 1. Server Transport (api)
`lib/api/client.dart` · `lib/api/events.dart`
- `OcClient` — typed HTTP wrapper, ~90 endpoints, `IOClient` keep-alive, isolate-parses bodies >32 KB (`client.dart:30,85`)
- `EventStream` — SSE `/event` with watchdog (75 s stale, `events.dart:60`), exp. backoff 1→15 s (`events.dart:190`), `_gen` generation guard
- `ApiException` (`client.dart:12`) normalises `{name,data}` envelope, Timeout, SocketException, FormatException (`client.dart:99-143`)

### 2. Data Contracts (models)
`lib/models/models.dart` — 21 model classes + `asMap/asList/asInt/asStr/asDouble/asBool` coercers (`models.dart:5-20`) + `fmtBytes/fmtTime/fmtAge/fmtDuration/baseName/dirName` (`models.dart:673-713`)
- Header comment: "mirroring the opencode server OpenAPI schemas. Verified against opencode 1.18.27 /doc spec." (`models.dart:1-2`)

### 3. State Core
`lib/state/store.dart` · `lib/main.dart`
- `OcStore extends ChangeNotifier` (`store.dart:43`) — 60+ public mutators, throttled `_scheduleNotify` 60 ms (`store.dart:118`), `ChatMessage` (`store.dart:12`), `PendingAttachment` (`store.dart:28`)
- `AppScope extends InheritedNotifier<OcStore>` (`main.dart:67`) — `of()` subscribes, `read()` doesn't
- `_handleEvent` SSE switch — 21 event families (`store.dart:974-1098`)

### 4. Chat Experience
`lib/ui/chat.dart` (2131 L) · `lib/ui/parts.dart` · `lib/ui/markdown.dart` · `lib/ui/line_icons.dart`
- 30 widget classes; single scroll owner + follow-mode (`chat.dart:29-33,141-145`)
- `PartTile`/`ToolTimeline`/`ToolTile`/`DiffText` (`parts.dart:13,21,215,506`)
- Custom markdown parser → `_Block` list (`markdown.dart:18,351`), global `_parseCache` (`markdown.dart:377`)
- Custom-drawn icon system `LI` + `LIcon` + `LLinePainter` (`line_icons.dart:17,96,186`)
- Empty state = `_Welcome` (`chat.dart:628`): hero → `_ModelModeChips` → `_ProjectBar` → 4 `SuggestionCard`s, pinned top/bottom by `IntrinsicHeight` + `ConstrainedBox(minHeight: viewport)` inside a `SingleChildScrollView`
- `SuggestionCard` (`chat.dart:949`) and `OutlinedChip` (`chat.dart:757`) are public so the hero and the composer share one card/chip implementation

### 5. Session & Task Screens
`lib/ui/sessions_page.dart` · `lib/ui/todos_page.dart` · `lib/ui/commands_page.dart` · `lib/ui/prompts.dart`
- `PromptOverlay` renders permissions/questions above any route (`prompts.dart:10-11`)

### 6. Workspace Screens
`lib/ui/files_page.dart` · `lib/ui/diff_page.dart` · `lib/ui/terminal_page.dart`
- Files/diff/terminal all shell out through the store's hidden util session (`store.dart:771`)

### 7. Design System
`lib/ui/theme.dart` · `lib/ui/primitives.dart` · `lib/ui/widgets.dart` · `lib/l10n/strings.dart`
- `OCColors`/`OCTokens`(ThemeExtension)/`OCSpace`/`OCRadius`/`OCMotion`/`OCTypography` (`theme.dart:11,115,367,397,416,438`)
- 22 `OC*` primitives (`primitives.dart:98`…)
- `pushScreen`/`showSnack`/`copyToClipboard`/`confirmDialog`/`promptText` (`widgets.dart:11,132,136,336`)
- Chat-screen roles: `OCSpace.screenGutter` (the one horizontal inset), `OCRadius.suggestion/.composer`, `OCMotion.pressScaleSoft`, `OCTypography.heroTitle/.meta`, `OCTokens.surfaceElevated` (composer) and `.warn` (reconnecting). `screenX` is the older 16dp alias.
- `ocReduceMotion` (`widgets.dart:469`) — the OS "remove animations" check every looping/scale animation must go through
- `OcLinkState`/`ConnectionPill`/`ocLinkState` (`widgets.dart:476-608`) — the header's 3-state status chip; fed by `OcStore.online` + `OcStore.reconnecting`
- `S` — 401 static strings (`strings.dart:9`); rule: "no string literals inside widgets" (`strings.dart:1-7`)

### 8. Shell & Settings
`lib/ui/home.dart` · `lib/ui/settings_page.dart` · `lib/ui/models_page.dart` · `lib/ui/about_page.dart` · `lib/ui/more_page.dart` (dead)
- `HomeShell` — 4-tab `IndexedStack`, More is a sheet not a tab (`home.dart:42-43`)

### 9. Build & Deploy
`.github/workflows/build.yml` · `deploy.py` · `setup.sh` · `pubspec.yaml` · `analysis_options.yaml` · `design/clean-chat-ui.html`
- CI: `flutter create .` (android only) → restore pubspec/lib/analysis_options → patch manifest → `flutter analyze --no-fatal-infos --no-fatal-warnings` → APK + split-per-abi (`build.yml:36-69`)
- `deploy.py` = `git add -A && commit && push` → GH Actions builds APK (`deploy.py:63-71`)

## God nodes

| degree | node (file) | why risky |
|---|---|---|
| 18 | `theme.dart` (`lib/ui/theme.dart`) | imported by 18 files; every pixel depends on it |
| 15 | `primitives.dart` (`lib/ui/primitives.dart`) | 22 shared widgets, 12 consumers |
| 14 | `widgets.dart` (`lib/ui/widgets.dart`) | nav/snack/dialog helpers used everywhere |
| 14 | `models.dart` (`lib/models/models.dart`) | every DTO; `asStr`-coercion failures are silent |
| 13 | `main.dart` (`lib/main.dart`) | owns `AppScope`; **cycle hub** (see Suspects) |
| 60+ | `OcStore` (`lib/state/store.dart:43`) | 60 `store.*` call sites across 12 files, 35 KB |
| 90 | `OcClient` (`lib/api/client.dart:33`) | every endpoint; single `IOClient` shared |
| ~45 | `chat.dart` (`lib/ui/chat.dart`) | 30 widget classes, 2131 lines |
| 13 | `LI`/`LIcon` (`lib/ui/line_icons.dart:17,96`) | new untracked file; enum used in 4 files |
| 4 | `EventStream` (`lib/api/events.dart:43`) | single point of truth for all live state |

## Edges

### imports (EXTRACTED 1.0)
```
main.dart            --imports[EXTRACTED]--> store.dart        (main.dart:5)
main.dart            --imports[EXTRACTED]--> ui/home.dart       (main.dart:6)
main.dart            --imports[EXTRACTED]--> ui/theme.dart      (main.dart:7)
store.dart           --imports[EXTRACTED]--> api/client.dart    (store.dart:8)
store.dart           --imports[EXTRACTED]--> api/events.dart    (store.dart:9)
store.dart           --imports[EXTRACTED]--> models/models.dart(store.dart:10)
api/client.dart      --imports[EXTRACTED]--> models/models.dart(client.dart:10)
api/events.dart      --imports[EXTRACTED]--> models/models.dart(events.dart:6)
ui/home.dart         --imports[EXTRACTED]--> ui/chat.dart      (home.dart:5)  [also 6,7,8,10-15]
ui/home.dart         --imports[EXTRACTED]--> ui/{diff,files,terminal,sessions,todos,more}_page.dart (home.dart:6-8,11,12,14)
ui/chat.dart         --imports[EXTRACTED]--> state/store.dart   (chat.dart:12)
ui/chat.dart         --imports[EXTRACTED]--> ui/{diff_page,models_page,parts,markdown,primitives,theme,widgets,line_icons}.dart (chat.dart:13-20)
ui/sessions_page.dart--imports[EXTRACTED]--> state/store.dart  (sessions_page.dart:7)
ui/settings_page.dart--imports[EXTRACTED]--> state/store.dart  (settings_page.dart:8)
ui/settings_page.dart--imports[EXTRACTED]--> ui/commands_page.dart (settings_page.dart:9)
ui/commands_page.dart--imports[EXTRACTED]--> ui/chat.dart      (commands_page.dart:6)
ui/diff_page.dart    --imports[EXTRACTED]--> ui/parts.dart      (diff_page.dart:5)
ui/parts.dart        --imports[EXTRACTED]--> ui/markdown.dart   (parts.dart:8)
ui/{models_page,settings_page}.dart --imports[EXTRACTED]--> api/client.dart (models_page.dart:3, settings_page.dart:5)  # DTO only
<every ui/*.dart>    --imports[EXTRACTED]--> ui/theme.dart      # 18 files
```
**Circular imports (EXTRACTED):**
```
main.dart --imports--> ui/home.dart --imports--> main.dart      (main.dart:6 ↔ home.dart:4)
```
`AppScope` living in `main.dart` is the only cycle. Legal Dart, but any `const` init across it is a landmine.

### calls — UI → store (EXTRACTED 1.0)
```
ChatPage          --send-->            OcStore.send                (chat.dart:282)
ChatPage          --send-->            OcStore.runCommand           (chat.dart:268)
ChatPage          --loadOlder-->       OcStore.loadOlderMessages    (chat.dart:181)
ReplyActions      --revert/fork-->     OcStore.revert/forkSession   (chat.dart:884,977 / 961)
MessageMenu       --deleteMessage-->   OcStore.api.deleteMessage    (chat.dart:995)
Composer          --attach/pick-->     OcStore.addAttachment        (chat.dart:1317,1338)
Composer          --image-->           ImagePicker (image_picker)   (chat.dart:1310)
SlashTextField    --toolIds-->         OcStore.api.toolIds          (chat.dart:1627)
SlashTextField    --findFiles-->       OcStore.api.findFiles        (chat.dart:1865)
FilePickerSheet   --files-->           OcStore.api.files            (chat.dart:2031)
HomeShell         --newSession/rename-->OcStore.newSession/renameSession (home.dart:79,379)
SessionsPage      --crud-->            OcStore.open/delete/fork/share/unshareSession (sessions_page.dart:230,199,272,303,294)
FilesPage         --write/mkdir/rm-->  OcStore.writeFile/mkdirEntry/deleteEntry (files_page.dart:527,292,321)
FilesPage         --shell-->           OcStore.runShell             (files_page.dart:262,275)
DiffPage          --vcs-->             OcStore.api.vcsDiff/vcsApply (diff_page.dart:52,309)
TerminalPage      --shell-->           OcStore.runShell             (terminal_page.dart:70)
SettingsPage      --cfg/mcp/auth-->    OcStore.saveConfig/addMcp + api.setApiKey/removeAuth (settings_page.dart:657,453,574,516)
ModelsPage        --pick-->            OcStore.setModel/setAgent    (models_page.dart:362,264)
PromptOverlay     --answer-->          OcStore.answerPermission/answerQuestion/rejectQuestion (prompts.dart:112,245,226)
TodosPage         --refresh-->         OcStore.refreshTodos         (todos_page.dart:19)
AboutPage         --reconnect-->       OcStore.connect              (about_page.dart:84)
```

### calls — store → client (EXTRACTED 1.0)
```
OcStore.connect   --health-->  OcClient.health      (store.dart:187)
OcStore.connect   --stream-->  EventStream.start   (store.dart:210-226)
OcStore.send      --prompt_async--> OcClient.promptAsync (store.dart:662)
OcStore.openSession --messages-->  OcClient.messages  (store.dart:368)
OcStore.runShell  --shell-->  OcClient.shell        (store.dart:795)
OcStore.writeFile --shell-->  runShell + base64 chunks (store.dart:808-829)
OcStore.refreshConfig --mcp/lsp/formatter--> OcClient.* (store.dart:865-867)
EventStream       --GET /event--> http.Client        (events.dart:107)
OcEvent.fromJson  ----> OcStore.handleEvent        (events.dart:167 -> store.dart:964)
```

### routes (server endpoints, EXTRACTED from client.dart)
`GET /global/health`:279 · `/path`:285 · `/vcs`:287 · `/config`:306 · `/provider`:320 · `/provider/auth`:324 · `/agent`:358 · `/session`(CRUD):363-430 · `/session/:id/message`:510 · `/session/:id/prompt_async`:538 · `/session/:id/command`:587 · `/session/:id/shell`:617 · `/session/:id/todo`:406 · `/session/:id/diff`:432 · `/file`,`/file/content`,`/file/status`:661-673 · `/find/file`,`/find`,`/find/symbol`:676-700 · `/vcs/diff`,`/vcs/status`,`/vcs/apply`:707-725 · `/mcp`:729 · `/lsp`,`/formatter`:750 · `/question`:762 · `/command`,`/skill`:644 · `/tui/:action`:777

### uses_config / external services (EXTRACTED)
```
pubspec.yaml  --uses--> http ^1.2.0, shared_preferences ^2.2.3, image_picker ^1.1.2, url_launcher ^6.2.0
OcStore       --writes--> SharedPreferences keys url,user,pass,agent,provider,model,tools,showTokens (store.dart:156-163)
deploy.py     --pushes--> github.com/…/opencode_app main -> GH Actions -> APK artifact (deploy.py:14,71; build.yml:74)
```
`config.json` (permission: edit/bash/external_directory = allow) is an **opencode server** config, git-ignored, not read by this app. AMBIGUOUS 0.3 — unclear if it is meant for this project's agent sandbox.

### semantically_similar_to (no direct link)
```
OcClient.events (client.dart:217)        ~ EventStream._connect (events.dart:91)   [INFERRED 0.8] two SSE parsers for the same endpoint
files_page.dart:_q (files_page.dart:332) ~ OcStore._shellQuote (store.dart:831)   [EXTRACTED duplicate logic]
settings_page _StatusRow (settings_page.dart:674) ~ prompts.dart cards              [INFERRED 0.6]
more_page _ConnectionCard (more_page.dart:94) ~ about_page.dart:59-114             [EXTRACTED duplicate]
```

## Surprising links (cross-community)

1. **UI bypasses the store and calls HTTP directly** — 22 `store.api.*` calls from widgets: `files_page.dart:48,55,351,506`, `diff_page.dart:47,52,55,309`, `settings_page.dart:135,158,179,261,264,516,574`, `sessions_page.dart:341`, `home.dart:282`, `chat.dart:995,1337,1627,1865,2031`. No caching, no error policy, no notification on failure. EXTRACTED.
2. **`chat.dart` imports `diff_page.dart` but never uses `DiffPage`** (chat.dart:13; zero `DiffPage` refs). Unused import. EXTRACTED.
3. **`more_page.dart` (4.2 KB) is imported by nobody** — `grep -rn more_page lib/` → NONE. Its own doc comment still claims "Reached from the last NavigationBar destination" (`more_page.dart:13-14`), but `home.dart` was rewritten to a 4-tab `IndexedStack` with More as a sheet (`home.dart:42-43`). Dead screen + dead nav entry. EXTRACTED.
4. **File editing runs shell commands on the server.** `FilesPage` save → `OcStore.writeFile` → base64 chunks → `runShell` → `POST /session/<util>/shell` (`store.dart:808-829`). There is no file-write endpoint; it composes `printf`/`base64 -d` over a hidden session titled `__opencode_app_util__` (`store.dart:768`). Hidden side effect: this session shows up in `GET /session` and in the user's history UI. INFERRED 0.9 (behaviour is EXTRACTED, the "shows in history" claim is INFERRED).
5. **`models_page.dart` + `settings_page.dart` import `api/client.dart` for `ProviderEntry` only** — the DTOs live in the transport layer instead of `models/`. Cross-community leak. EXTRACTED.
6. **Theme is code, and it is duplicated as data** — `design-system.json` (22 KB) + `design/clean-chat-ui.html` (25 KB, untracked) + `lib/ui/theme.dart` (33 KB). Three copies of the same visual language; nothing verifies they agree. INFERRED 0.7.
7. **`store.toolsEnabled.clear()` from the UI** (`chat.dart:1651`) mutates store internals with no `notifyListeners()`. State contract broken. EXTRACTED.
8. **`l10n/strings.dart` is 70% dead**: 282 of 401 `S` members are referenced nowhere; 8 of 14 UI files import it not at all and hardcode Hinglish strings (e.g. `settings_page.dart:92`, `files_page.dart:209`, `prompts.dart:66`). AMBIGUOUS 0.3 — is l10n a planned rollout or abandoned?
9. **9 of 22 `OC*` primitives are dead** — `OCChip`, `OCBreadcrumbs`, `OCFilterButton`, `OCAvatar`, `OCAvatarStack`, `OCToggle`, `OCSkeleton`, `OCCardVariant`, `OCStatus` (`primitives.dart:538,543,626,699,1054,1258,1368,1428,347`). EXTRACTED (grep-verified).

## Suspects

**Blocking**
- `LI.close` does not exist in `enum LI` (`line_icons.dart:17-94`) but is used at `chat.dart:514` → **this does not compile**. `line_icons.dart` is untracked (`git status: ?? lib/ui/line_icons.dart`) — the new icon file was never completed. CI would fail at `flutter analyze`. EXTRACTED, high confidence.

**Dead code**
- `more_page.dart` whole file unreferenced (`more_page.dart:15`) — stale doc comment too.
- `ShareCard` (`prompts.dart:341`) — public, zero references.
- `visibleSessions` (`sessions_page.dart:67`), `HomeShellState` (`home.dart:39`) — public but file-local.
- `PartTile.compact` (`parts.dart:213`) — declared, never read.
- `_BusyBar.status` never rendered (`chat.dart:323,527`) → `busyStatus` set in 6 places (`store.dart:380,463,639,658,1002,1012`) is dead data.
- Dead `LI` glyphs: `search, check, dot, spark, refresh, download, keyboard, settings, done` — ~180 lines of `_draw` cases with no call site.
- Dead ternary: `chat.dart:1899` both branches `''`; `markdown.dart:346` both branches `t.accSoft`.
- 282 unused `S` members; 5 printf-style strings nothing formats (`strings.dart:281,373,375,396,478`).

**Unawaited / unhandled async (silent failure)**
- `store.revert()` never awaited, no catch (`chat.dart:884,977`)
- `store.setAgent()` is `Future<void>`, not awaited (`chat.dart:1590`)
- `store.openSession(store.current!.id)` in error-bar retry: unawaited + force-unwrap (`chat.dart:305`)
- `await store.loadOlderMessages()`, `await store.runCommand()`, `await store.forkSession()` with no try (`chat.dart:181,268,961`)
- `await store.mkdirEntry/send/deleteEntry` no try (`files_page.dart:292,302,321`) while siblings do catch
- `refreshConfig()` in `initState` unawaited (`settings_page.dart:25`)
- `store.unshareSession/shareSession/answerPermission/answerQuestion` fire-and-forget (`sessions_page.dart:294,303`, `prompts.dart:112,245`)

**Silent catch**
- `chat.dart:1871` swallows `findFiles` failures; `files_page.dart:56` swallows `fileStatus` → count silently 0; `diff_page.dart:62` swallows `vcsStatus`; `files_page.dart:353` renders `LoadingView` for errors *and* pending → infinite spinner in `ChangedFilesPage`; `store.dart:239,248,258,476,487,511,776,856,868,920` — ten `catch (_) {}` in the store.

**Duplicated logic**
- Message-text extraction 3× (`chat.dart:701,874,949`)
- Filename fallback 2× (`chat.dart:1067`, `parts.dart:603`)
- Extension→type map 2× (`chat.dart:1353` `_mimeFor`, `chat.dart:2116` `_iconFor`)
- Tool summary/duration/exit lines 2× (`parts.dart:85,157` vs `427,436`)
- Shell quoting 2× (`store.dart:831`, `files_page.dart:332`) ← **security-relevant divergence**
- `_ConfigEditor.didUpdateWidget` compares maps by identity (`settings_page.dart:604-608`) → in-progress edits silently discarded on any store re-assignment

**Leaked internals / lifecycle**
- `TapGestureRecognizer` per link in a `StatelessWidget`, never disposed (`markdown.dart:323-334`)
- Global `_parseCache` retains up to 40 full markdown strings process-wide (`markdown.dart:377-389`)
- `_syncFollow()` runs inside `build` and can call `setState` (`chat.dart:220,127`) — safe only by accident
- `store.password` persisted in plaintext `SharedPreferences` (`store.dart:158`)

**AMBIGUOUS (flagged, not resolved)**
- 0.3 `config.json` — whose config is it? Ignored by the app.
- 0.3 `graphify_lite.py` (610 L, untracked) — a Python graph tool living in this repo; same job as this CODEMAP. Not wired into anything I can see.
- 0.3 `project_structure.txt` — stale: lists 24 files, omits `about_page`, `more_page`, `primitives`, `theme`, `line_icons`, `l10n/`.
- 0.0 `OcClient.events`/`eventsAutoReconnect` — RESOLVED 2026-10-04: grep-verified unused (`EventStream` in `api/events.dart` is the only live SSE path) and deleted. `OcClient` is now request/response only.

## Learned

- 2026-10-02 — App is a 3-layer Flutter client: transport (`api/`) → state (`state/store.dart`) → UI (`ui/`), no external state manager, `AppScope` InheritedNotifier is the only channel (60 call sites).
- 2026-10-02 — Live updates are 100% SSE-driven via `EventStream`; polling only on boot/reconnect (`store.dart:193-199`, `store.dart:229-242`).
- 2026-10-02 — File writes have no API; they are shell commands over a private `__opencode_app_util__` session (`store.dart:768-829`).
- 2026-10-02 — Repo is mid-refactor: 9 modified files + `line_icons.dart`, `design/`, `graphify_lite.py` untracked. `home.dart` moved from a NavigationBar+MoreTab to 4 IndexedStack tabs, orphaning `more_page.dart`.
- 2026-10-04 — `OcClient` (`api/client.dart`) is strictly request/response now: the legacy `events()`/`eventsAutoReconnect()` generators are deleted, so there is exactly one SSE implementation in the repo — `EventStream` (`api/events.dart`), which owns reconnect, backoff, liveness probing and pause/shutdown.

## Last scan

2026-10-02 23:12 · mode `/map opencode_chat` · 25 `.dart` + 2 `.yaml` + `build.yml` + `deploy.py` + `setup.sh` + 2 design artifacts.

```
0d1c4180  .github/workflows/build.yml
ae30aa4b  analysis_options.yaml
8216e5ff  deploy.py
9ffbcf46  design/clean-chat-ui.html
5b2aa554  lib/api/client.dart
1ae43462  lib/api/events.dart
0c209021  lib/l10n/strings.dart
3efa4748  lib/main.dart
94bc1829  lib/models/models.dart
85f66375  lib/state/store.dart
ca9bddec  lib/ui/about_page.dart
e09aaf48  lib/ui/chat.dart
7fe1dc63  lib/ui/commands_page.dart
93dc4508  lib/ui/diff_page.dart
0990b1d8  lib/ui/files_page.dart
dc2467e0  lib/ui/home.dart
c720ac5c  lib/ui/line_icons.dart
41994c2b  lib/ui/markdown.dart
cf9f0ace  lib/ui/models_page.dart
342bbab3  lib/ui/more_page.dart
9914c602  lib/ui/parts.dart
8def0ae0  lib/ui/primitives.dart
5c7e3bc5  lib/ui/prompts.dart
6be6c644  lib/ui/sessions_page.dart
7539a38f  lib/ui/settings_page.dart
0cd5b98e  lib/ui/terminal_page.dart
37021a42  lib/ui/theme.dart
0cb6bac4  lib/ui/todos_page.dart
528e63d2  lib/ui/widgets.dart
fc911d20  pubspec.yaml
eb700848  setup.sh
```