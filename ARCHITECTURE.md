# OPENCODE_CHAT — COMPLETE ARCHITECTURE & WORKFLOW
### Single-file reference for an AI agent that has never seen this repo

> Everything below is extracted from the source at the cited `file:line`.
> If a claim here contradicts the code, the code wins — but check the cited line first.

---

## 0. WHAT THIS APP IS, IN ONE PARAGRAPH

`opencode_chat` is a **Flutter (Android) client for the `opencode` coding-agent server**.
It is *not* an AI model. It is a **remote control + rich renderer** for an agent process
that runs somewhere else (typically a phone's Termux, or a PC on the same LAN).

- The **server** owns everything: the LLM calls, the tool execution, the shell, the file
  system, the git repo, the session history.
- The **app** owns nothing but: presentation, a local cache for offline reading, and user
  preferences.
- All live data flows over **two channels**: ordinary HTTP request/response
  (`OcClient`) and one long-lived **SSE** stream (`EventStream`).
- The app has **no offline compute**. If the server is down, you can still *read* cached
  chats; you cannot chat, run commands, or edit files.

```
┌──────────────────────────────┐
│  ANDROID APP (this repo)      │
│                              │
│  Flutter UI ──► OcStore ──►  OcClient (HTTP, pooled, keep-alive)
│  (widgets)      (state)   └─► EventStream (SSE /event)
│                    │                      │
│                    └──► ChatDB (sqflite)   │
│                         local cache       │
└──────────────────────────────┬────────────┘
                               │ HTTP + SSE
                               │ (plain http, LAN/loopback)
                               ▼
┌──────────────────────────────────────────────┐
│  OPENCODE SERVER  (`opencode serve`)          │
│  host: Termux on the same phone  OR  a PC     │
│  default: http://127.0.0.1:4096               │
│                                              │
│  • runs the agent (build/plan/general)        │
│  • runs tools (bash/read/write/edit/grep)     │
│  • owns ~/.config/opencode, the project dir   │
│  • pushes SSE events on every state change    │
└──────────────────────────────────────────────┘
```

**Key consequence:** the app never asks for `MANAGE_EXTERNAL_STORAGE` for its own
file work, because files are written by the *server's* shell, not by the app process.
This is deliberate and documented at `lib/state/store.dart:398-401` and
`lib/state/store.dart:1526-1530`.

---

## 1. FILE MAP — every file, one line

| File | Lines | Role |
|---|---|---|
| `lib/main.dart` | 73 | App entry. Creates the single `OcStore`, calls `store.boot()`, wires `AppScope` + `MaterialApp`, handles app lifecycle. |
| `lib/state/store.dart` | 2165 | **The brain.** `OcStore extends ChangeNotifier`. All app state + every mutation + the SSE event router. |
| `lib/api/client.dart` | 843 | `OcClient` — typed HTTP wrapper, ~90 endpoints, keep-alive `IOClient`, isolate JSON parsing for >32 KB, error normalisation. Also `ProviderInfo`/`ProviderEntry`/`AuthMethod` DTOs. |
| `lib/api/events.dart` | 428 | `EventStream` — SSE `/event` consumer with watchdog liveness probes, exponential backoff, generation guard. `OcEvent` = one decoded frame. |
| `lib/db/chat_db.dart` | 234 | `ChatDB` — sqflite cache of messages + session list. Serialised write queue. |
| `lib/models/models.dart` | 743 | 21 model classes mirroring the server OpenAPI, plus type coercers `asMap/asList/asInt/asStr/asDouble/asBool` and formatters `fmtBytes/fmtTime/fmtAge/fmtDuration/baseName/dirName`. |
| `lib/l10n/strings.dart` | 944 | Class `S` — every user-visible string. Rule: **no string literals inside widgets.** |
| `lib/ui/app_scope.dart` | 22 | `AppScope extends InheritedNotifier<OcStore>` — DI without a package. `of()` subscribes, `read()` does not. |
| `lib/ui/home.dart` | 734 | `HomeShell` — header + 4 tabs in an `IndexedStack` + bottom nav + the "More" sheet. |
| `lib/ui/chat.dart` | 2982 | The chat screen: transcript, follow-mode scrolling, composer, slash/@ autocomplete, suggestion cards, message menu. |
| `lib/ui/parts.dart` | 963 | Renders message parts: tool timeline, thinking group, files, patches, retries, diffs. |
| `lib/ui/markdown.dart` | 589 | Hand-written markdown parser → `_Block` list → widgets. Global parse cache. |
| `lib/ui/line_icons.dart` | 648 | Custom-drawn icon set: enum `LI`, `LIcon` widget, `LLinePainter`. No icon font. |
| `lib/ui/theme.dart` | 934 | `OCColors`, `OCTokens` (ThemeExtension), `OCSpace`, `OCRadius`, `OCMotion`, `OCTypography`, `buildAppTheme()`. |
| `lib/ui/primitives.dart` | 1544 | 22 `OC*` building blocks: `OCButton`, `OCCard`, `OCIconTile`, `OCToggle`, `OCSegmentedControl`, `OCProgressRing`, `OCSkeletonList`, … |
| `lib/ui/widgets.dart` | 917 | App-level helpers: `pushScreen`, `showSnack`, `showToast`, `showUndoSnack`, `copyToClipboard`, `promptText`, `confirmDialog`, `EmptyHint`, `LoadingView`, `ConnectionErrorView`, `StatusPill`, `ocLinkState`, `AppHeader`. |
| `lib/ui/sessions_page.dart` | 772 | Session list: search, filter, grouped by date, swipe-to-delete + undo, long-press actions, error-guarded rows. |
| `lib/ui/files_page.dart` | 806 | Remote file browser + `ChangedFilesPage` + `FileEditorPage` (read/save via server shell). |
| `lib/ui/diff_page.dart` | 482 | Session diffs and git (worktree/staged/all) diffs with a unified-diff renderer. |
| `lib/ui/terminal_page.dart` | 293 | Shell over the server's util session. Command history, shortcuts, wrap toggle. |
| `lib/ui/todos_page.dart` | 152 | The agent's todo list for the current session. |
| `lib/ui/commands_page.dart` | 223 | Slash commands + skills browser. |
| `lib/ui/models_page.dart` | 426 | Provider/model picker with search + connected-only filter. |
| `lib/ui/settings_page.dart` | 724 | Server URL, session actions, provider API keys, raw config editor, MCP. |
| `lib/ui/about_page.dart` | 119 | App info + server status. |
| `lib/ui/prompts.dart` | 363 | `PromptOverlay` — permission requests + agent questions, drawn **over every route**. |
| `deploy.py` | 94 | `git add -A && commit && push` → GitHub Actions builds the APK. |
| `setup.sh` | — | Termux one-shot: installs `opencode-start` / `opencode-stop`, optional Termux:Boot autostart. |
| `.github/workflows/build.yml` | — | CI: `flutter create .` (android only) → patch manifest → analyze → release APK. |

There is **no `android/` directory in the repo** — CI generates it. There are **no tests.**

---

## 2. BOOT SEQUENCE

`main()` → `runApp(OpenCodeApp)` (`lib/main.dart:8-11`).

1. `_OpenCodeAppState.initState` creates `final store = OcStore()` and calls
   `store.boot()` (`lib/main.dart:21-28`).
2. `OcStore.boot()` (`lib/state/store.dart:407-421`):
   - loads `SharedPreferences`
   - restores: `url`, `user`, `pass`, `agent`, `provider`, `model`, `tools`, `showTokens`
   - sets `booted = true`, `notifyListeners()`
   - `await connect()`
3. `connect()` (`lib/state/store.dart:448-494`):
   - **re-entrancy guard** `_connecting` — a second Retry tap cannot race
   - `fatalError = null`, `online = false`, pushes url/user/pass into `api`
   - `api.health()` with an 8 s timeout →
     - **success**: `serverVersion = h.version`, `online = true`, `_startStream()`,
       then `Future.wait([refreshCatalog, refreshSessions, refreshServerInfo,
       refreshCommands, loadPending])`
     - **`ApiException`**: `fatalError = e.message`, `_restoreSessionsFromCache()`
     - **anything else**: `fatalError = _offlineMessage()`, `_restoreSessionsFromCache()`
4. `_startStream()` (`lib/state/store.dart:566-584`) shuts down any old stream and
   creates a fresh `EventStream` with `onEvent: handleEvent`, `onStatus: _onStreamStatus`,
   `isBusy: () => busy`.
5. `HomeShell.build` (`lib/ui/home.dart:70-114`):
   - `!store.booted` → `LoadingView`
   - `store.fatalError != null && store.sessions.isEmpty` → `ConnectionErrorView`
     (**only when there is genuinely nothing to show** — cached sessions keep the tabs usable)
   - otherwise → `IndexedStack(index, [ChatPage, SessionsPage, FilesPage, TerminalPage])`
6. `PromptOverlay` is mounted as `Positioned.fill` **on top of the whole stack**
   (`lib/ui/home.dart:101`), so a permission request survives any tab or pushed route.

### Persistence keys (`SharedPreferences`)
`url`, `user`, `pass`, `agent`, `provider`, `model`, `tools` (StringList), `showTokens` (bool)
— written by `_persist()` at `lib/state/store.dart:423-434`.

---

## 3. CONNECTION STATE MACHINE — the most subtle part of this app

The app distinguishes **four** UI states, not two (`lib/ui/widgets.dart:491-506, 669-680`):

| `OcLinkState` | Condition | Shown as |
|---|---|---|
| `connected` | `online && !reconnecting` | green dot, "Connected" |
| `reconnecting` | `online && reconnecting` | pulsing amber dot, "Reconnecting" |
| `offline` | `!online && no cached sessions` | red dot, "Offline" + Retry |
| `offlineCached` | `!online && cached sessions exist` | red dot, "Offline (cached)" |

**The rule that makes this correct:** a dropped SSE socket does **not** mean the server is
down. A socket can die on a healthy server (Android battery freeze, wifi handover, OS-reaped
socket), and the server can die while the socket still looks open. Only the server can tell
them apart — so the app **asks the server** (`/global/health`) before changing `online`.

### The two flags
- `online` — last *proven* reachability of the server (HTTP health probe).
- `reconnecting` — the SSE stream is down but reachability has not been disproved.
  `lib/state/store.dart:105-108`

### EventStream resilience (`lib/api/events.dart`)

| Constant | Value | Line | Meaning |
|---|---|---|---|
| `_staleAfter` | 90 s | `:72` | silence ⇒ *suspect*, start probing |
| `_staleWhileBusy` | 180 s | `:80` | silence **while a run is in flight** ⇒ dead even if probe passes |
| `_probeEvery` | 15 s | `:83` | liveness-check cadence once stale |
| `_probeFailures` | 2 | `:87` | consecutive failed probes before giving up |
| `_connectTimeout` | 10 s | `:97` | TCP connect |
| `_handshakeTimeout` | 20 s | `:98` | response headers for the SSE GET |
| `_socketIdle` | **10 min** | `:99` | dart:io defaults this to **15 s**, which used to kill the SSE stream every time the agent went quiet. Never lower it. |
| backoff | 1 s → 15 s | `:379-382` | `1000 * (1 << (attempt.clamp(1,5) - 1))`, capped 15000 |

Core algorithm:
```
_connect():  gen = ++_gen   (CLAIM THE GENERATION *BEFORE* THE FIRST AWAIT — this is
                            what stops resume/retry/manual-reconnect from racing and
                            orphaning a socket, events.dart:150-157)
             teardown old
             GET $root/event  with Accept: text/event-stream
             != 200  → scheduleRetry (401 after a password change, 404 on an old
                       server; still retry — a Termux restart recovers itself)
             == 200  → reset backoff, _setConnected(true), start watchdog,
                       parse frames: split on "\n\n", collect "data:" lines
```

Liveness (`_probeLiveness`, `events.dart:261-324`):
- runs on a **separate** socket, because a pooled connection cannot be trusted to be the
  thing that broke
- probe OK + idle → **not** a failure; just push the next check a full window out
- probe OK + busy + silence ≥ 180 s → events are being lost → reconnect (this is what stops
  answers being truncated)
- probe OK + busy + silence < 180 s → restart the silence window (long `sleep`/build is fine)
- probe fail + busy → conclusive immediately (`_probeFails = _probeFailures`)
- probe fail + idle → needs 2 consecutive failures

`_markDown` (`:353-360`) reports an outage **exactly once per cycle**, so the UI never shows
a green dot over a dead stream. `reconnect()` deliberately emits the down edge even when
already down, so the owner's recovery path (resync) always runs exactly once.

`stop()` = pause (reversible, silent). `shutdown()` = final (`reconnect` refuses after it,
so a late lifecycle callback cannot resurrect a stream into a disposed store).

### Store side

- `_onStreamStatus(false)` (`store.dart:588-598`) → sets `reconnecting = true`, then
  `_verifyReachability()`. It **never** sets `online = false` directly.
- `_onStreamStatus(true)` (`store.dart:599-614`) → `online = true`, `reconnecting = false`,
  then **three catch-up repairs**, because events missed while disconnected are gone forever:
  1. `loadPending()` — a permission/question asked while away has no event left to deliver it
  2. `_resyncMessages(current.id)` — the server's own page is the only authority
  3. `_probeBusyState()` if `busy` — a run that finished while away never sent its idle event
- `_verifyReachability()` (`store.dart:511-564`) → `api.health()` (6 s). If up:
  `reconnecting = !(_stream?.live)`, and if the stream cannot come up at all it performs
  the same three repairs itself. If `full` (app resume): also `refreshSessions()` +
  `refreshServerInfo()`.

### App lifecycle (`lib/main.dart:38-54`)

| State | Action |
|---|---|
| `resumed` | `store.resumeConnections()` → `reconnectStream()` **+** `_verifyReachability(full: true)` |
| `paused` / `detached` | `store.pauseConnections()` → `_stream.stop()`, clear busy timer, flush history to disk |
| `inactive` | **nothing** — it fires for the notification shade / app picker / system dialogs; pausing there killed the live stream while the user was still looking at it |

Do **not** re-open the session on resume: reloading the message list wipes the on-screen chat
and makes an in-flight reply vanish (`main.dart:45-47`). The reconnected stream resyncs in place.

`resumeConnections` assumes the socket is dead rather than trusting it — Android may have
frozen the process for minutes (`store.dart:2139-2148`).

---

## 4. THE FULL CHAT FLOW — user hits send

```
_user types + taps send (or picks a suggestion card)_
  │
  ├─ ChatPage._send()                             chat.dart:330-366
  │    ├─ text starts with '/' and matches a known command?
  │    │     → store.runCommand(cmd, args)        chat.dart:336-347
  │    ├─ providerId/modelId empty?
  │    │     → showSnack(S.modelMissing) and stop  chat.dart:349-352
  │    └─ store.sendOrQueue(text)                  chat.dart:359
  │
  ├─ OcStore.sendOrQueue()                        store.dart:1107-1119
  │    ├─ store.busy ?  → push text into _queued, return  (never dropped,
  │    │                   never sent concurrently)
  │    └─ else → send(text)
  │
  ├─ OcStore.send()                               store.dart:1134-1205
  │    ├─ no current session? → newSession() first            :1138-1143
  │    ├─ parts = [attachment file parts] + [text part first] :1145-1147
  │    ├─ clearAttachments()                                :1149
  │    ├─ _clearLocalEcho() + drop stale optimistic rows    :1153-1156
  │    ├─ OPTIMISTIC BUBBLE: id = 'local-<epochMs>',
  │    │   raw {'optimistic': true}, local parts get ids
  │    │   prefixed 'part-local-'                          :1159-1200
  │    └─ _sendParts(sid, parts)                           :1204
  │
  ├─ OcStore._sendParts()                         store.dart:1321-1366
  │    ├─ no provider/model → toast S.pickModelFirst
  │    ├─ busy = true IMMEDIATELY (instant feedback, don't wait for server)
  │    ├─ _startBusyTimer()   (15 s watchdog, §6)
  │    └─ api.promptAsync(sid, provider, model, agent, parts, tools: toolMap)
  │         → POST /session/{id}/prompt_async    client.dart:514-534
  │         (fire-and-forget; 60 s timeout is only for the ACK)
  │    └─ on error: busy = false, sessionError = e.message,
  │                 REMOVE the optimistic bubble                  :1345-1365
  │
  └─ Server starts working. Everything after this arrives over SSE.
```

**Why `prompt_async` and not `prompt`:** `prompt()` blocks for up to 30 minutes and returns
the finished reply. The chat UI would freeze. `promptAsync` returns immediately and progress
arrives as events (`client.dart:536-561` documents this).

**No system prompt is sent.** An earlier version instructed the model to reply in
Roman-script Hinglish; that was the cause of Hinglish UI strings in the first place and was
removed (`store.dart:1326-1330`). One language: English.

### What the user sees while it runs
- 2 dp accent hairline under the header (`_RunProgressLine`, `chat.dart:2818`), **not** a
  full-width strip — a strip pushed the transcript out of view during exactly the runs that
  needed watching (`chat.dart:296-300`).
- `_WorkingStrip` above the composer's tool row: agent name + Stop (`chat.dart:1754, 2704`).
- `_QueuedStrip` when prompts were typed during the run (`chat.dart:1755, 2771`).
- The send button becomes a **Stop** button while `busy` (`chat.dart:2270-2278`).

---

## 5. SSE EVENT ROUTER — every event, every action

`OcStore._handleEvent` (`lib/state/store.dart:1747-1895`). Wrapped by `handleEvent`
(`:1737-1745`) so **one malformed event can never kill the handler or the stream**.

| Event | Action |
|---|---|
| `message.updated` | `_touchActivity()`, `_upsertMessage(info)` |
| `message.part.updated` | `_touchActivity()`, `_upsertPart(part)` |
| `message.part.delta` | `_touchActivity()`, `_applyDelta(partID, field, delta)` — this is the token stream |
| `message.part.removed` | `_removePart(sessionID, partID)` |
| `message.removed` | `_removeMessage(sessionID, messageID)` + DB delete |
| `session.status` | `busy = (status.type == 'busy')`; on busy→idle release the queue; start/clear the busy timer |
| `session.idle` | clear timer, `busy = false`, **flush history to disk now**, flush the prompt queue, refresh todos/diff/sessions |
| `session.error` | `sessionError = _errorText(...)`, `busy = false`, `_settleStuckStreaming()`, release the queue |
| `session.updated` / `session.created` | `_upsertSession` + save to DB |
| `session.deleted` | remove from list, clear `current` if it was current, wipe DB rows |
| `session.diff` | `liveDiff = …` (current session only) |
| `permission.asked` / `.updated` / `permission.v2.asked` | add `PermissionReq` (dedup by id); v2 parsed by `fromV2` |
| `permission.replied` / `.v2.replied` | remove from `permissions` |
| `question.asked` / `question.v2.asked` | add `QuestionReq`; **also force `busy = false`** because the question tool pauses the agent and the composer must be usable |
| `question.replied` / `.rejected` / `.v2.replied` | remove from `questions` |
| `todo.updated` | `_debouncedTodos()` — 600 ms debounce; used to fire an HTTP call + rebuild on every event (`store.dart:1884-1886`, `:211-216`) |
| `server.connected` | `online = true` |
| `file.edited`, `lsp.updated`, `mcp.tools.changed`, `installation.updated` | ignored (no refetch) |

**Session isolation:** `_isCurrent(sid)` (`store.dart:1906-1907`) guards every message/diff/
status mutation, so with no open session events from other sessions cannot leak in.
Session-list events (`session.updated/created/deleted`) are intentionally global.

---

## 6. STREAMING, THE BUSY WATCHDOG, AND "STUCK" MESSAGES

### `ChatMessage.streaming` (`store.dart:38-43`)
```dart
streaming => !settled
          && info.finishReason.isEmpty
          && !info.completed
          && info.role == 'assistant'
          && displayError == null;
```
`time.completed` is checked **as well as** the finish reason, because a stopped or failed
run leaves the finish reason empty — that used to keep the typing dots spinning forever and
hide the error.

### Busy watchdog (`store.dart:1210-1300`)
```
Timer.periodic(15 s):
  !busy                      → cancel timer
  silence > 45 s             → _probeBusyState()   (ask the server, don't guess)
  silence > 5 min            → give up: busy = false, _settleStuckStreaming(),
                                sessionError = S.errNoActivity
```
`_probeBusyState()` (`:1252-1295`) only a **definite** "not busy" clears the spinner, so a
flaky link cannot unlock the composer mid-run. A failed probe restarts the silence window
only up to 3 failures — after that the 5-minute bail-out can actually fire.
If the server says idle but the closing `message.updated` was lost, it calls
`_settleStuckStreaming()` **and** `_resyncMessages(id)` so the answer is not left cut off.

### `_settleStuckStreaming()` (`store.dart:1310-1319`)
Sets `settled = true` on every trailing streaming message. Only called on paths where the
store has **already decided** the run is over (abort, error, lost-event probe), so it can
never cut a genuinely live message short. Returns `true` if anything changed so callers can
skip a pointless rebuild.

---

## 7. THE OPTIMISTIC-ECHO HANDOVER (the trickiest UI logic)

When you send, the app draws your bubble immediately with a **fake id**
`local-<epochMs>` and `raw {'optimistic': true}`. The server never knows that id, so the
hand-over needs a two-step protocol:

1. **`message.updated` arrives** for the real user message. `message.updated` carries **no
   parts**. Swapping the local row for it right there would leave the row with nothing to
   render — the user's own message would visibly vanish. So for a real *user* message the
   store replaces the row in place, keeping the local parts (`store.dart:1960-1965`).
   For an assistant message there is no local bubble, so `_upsertPart` does the swap later.
2. **`message.part.updated` arrives** with the real `messageID`. `_upsertPart` now adopts
   the real id and retires the local stand-in parts (`store.dart:1980-1988`).

Two supporting mechanisms:

- **`_stripEchoedOptimistic(list, window)`** (`store.dart:300-328`): if the
  `message.updated` echo is *missed* (SSE dropped while backgrounded), the next resync
  brings the confirmed message in while the local bubble is still standing. Because ids
  cannot match, both would render. The fix compares **content + ordering** (only one prompt
  is ever in flight) with a 5 s clock skew tolerance (`_echoSkewMs`, `:272`).
- **Local part dedupe** (`store.dart:2022-2031`): ids are deduped by id, so the server's
  echo would be *appended* next to the local stand-in and the text (and every attachment
  chip) would render twice. Local parts are identified by the `'part-local-'` prefix
  (`_localPartPrefix`, `:1922`) and removed on content match — file parts match on
  filename, so sibling attachments survive.

`ChatMessage.parts` is always copied into a **growable** list (`store.dart:25-28`). Passing
`const []` used to make `parts.add()` throw, so streamed parts never appeared.

---

## 8. HISTORY LOADING & PAGINATION

- **Page size on open = 500** (`OcStore.pageLimit`, `store.dart:974`). Deliberately generous:
  the documented `before` query parameter answers `HTTP 400 {"_tag":"BadRequest"}` on
  opencode 1.18.27, so server-side backwards pagination is unavailable there.
- **Open** (`openSession`, `store.dart:800-857`):
  1. `_flushHistory()` — land the previous session's last streamed chunk first
  2. `_historyLoadGen++` — invalidate in-flight loads for the old session
  3. reset everything, `messagesLoading = true`
  4. **paint cached history first** so the chat is readable immediately (and stays readable
     if the server never answers)
  5. `api.messages(id, limit: 500)`
  6. `messages = _mergeHistory(cached, fetched)` — **merge, never replace**
  7. `hasMoreMessages = messages.length > fetched.length || fetched.length >= limit`
  8. `_persistHistory(id, fetched)`, then `/session/status` to learn `busy`, then
     `refreshTodos()` + `refreshDiff()`
- **`_mergeHistory`** (`store.dart:250-267`): keeps cached messages whose
  `info.created` is **older than** the server window's newest; inside the window the server
  copy is authoritative. Then `_stripEchoedOptimistic`.
- **Load older** (`loadOlderMessages`, `store.dart:1026-1061`): preferred path
  `?limit=60&before=<oldestId>`. On `ApiException` → `_widenHistory` (`:998-1024`): refetch
  with `limit = _limit*4` (capped 5000) and splice in what that reveals. Uses only `limit`,
  which every build supports, so history never dies at the first page.
- **Cursor integrity:** after a merge or prepend, `_oldestMessageId` is reset to
  `messages.first.info.id` — otherwise "load older" would skip a page.
- **Generation guard:** `_historyLoadGen` is captured before every await and re-checked
  after, so a session switch mid-load discards the result.
- **Scroll restoration** on prepend (`chat.dart:231-248`): measure `maxScrollExtent` before
  and after, then `jumpTo(beforePixels + grew)`. Never a guessed constant.

---

## 9. LOCAL CACHE (sqflite) — `lib/db/chat_db.dart`

DB: `getApplicationDocumentsDirectory()/opencode_chat.db`, **version 2**.
Tables: `messages(id PK, session_id, data JSON, created_at)` + index on
`(session_id, created_at)`; `sessions(id PK, data JSON, updated_at)` + index on `updated_at`.

Two rules keep the cache trustworthy (documented at `chat_db.dart:12-20`):
1. **Ordering comes from the server's own `info.time.created`**, never from write time.
   Writing `DateTime.now()` collapsed every timestamp to "now" on each rewrite, which made
   `ORDER BY` return messages in arbitrary order on the next load. Fallback: a monotonic
   `_seq` counter (`:33`, `_sortKey` `:107-116`).
2. **All writes are serialised through a `_queue` chain** (`:94-105`). Streaming fires a
   write per token; concurrent writes let a stale snapshot commit *after* a newer one and
   silently roll the cached text back. A failed write does not poison the chain.
   Reads go through the same queue.
   Tie-break on load: `ORDER BY created_at ASC, rowid ASC` (`:175`).

v1→v2 upgrade **drops the messages table** (`:52-59`): v1 rows are already in arbitrary
order and cannot be repaired without re-reading every blob. The next open repopulates.

### What gets cached — `_isCacheable` (`store.dart:235-242`)
Excluded: empty id, `raw['optimistic'] == true` (local echo), empty `raw`, and
**assistant messages still streaming** (no `finishReason`). Writing those early only risks
resurrecting an empty bubble or a truncated answer.

### Write strategy
- **Streaming:** `_scheduleFlush(sessionId, msg)` (`:358-371`) snapshots only the touched
  message into `_dirty`, debounced **400 ms**. Switching sessions forces an immediate flush
  first (snapshots are keyed by session).
- **Page loads:** `_persistHistory` writes the whole filtered page.
- **Forced flush points:** before a session switch (`openSession`), on `session.idle`
  (so killing the app right after a reply still keeps it), on
  `pauseConnections()` (Android can kill a backgrounded process), and on `dispose`.
- **Per-message delete:** `_removePart` re-marks only the affected messages so a dropped
  part is not resurrected from the cache on the next open.
- **Errors are swallowed** with a `debugPrint` — a broken cache must never block opening a
  session (`_cachedHistory` returns `[]`, `:332-348`).

### Offline behaviour
`_restoreSessionsFromCache()` (`store.dart:763-780`) repopulates the session list from disk
so cached chats stay reachable with the server down. `ConnectionErrorView` takes over the
**whole app only** when `fatalError != null && sessions.isEmpty` (`home.dart:220-225`).

---

## 10. PERMISSIONS & QUESTIONS — `lib/ui/prompts.dart`

`PromptOverlay` is a `Positioned.fill` layer above the whole `IndexedStack`
(`home.dart:101`), so a tool approval is never lost behind a pushed route. It shows
`questions.first` if any, else `permissions.first`.

- **Permission card** — calls `store.answerPermission(p, response)`
  (`store.dart:1699-1711`), which routes to the **v2** endpoint
  `POST /session/{sid}/permissions/{id}` when `p.sessionId` is non-empty, otherwise the
  **v1** endpoint `POST /permission/{id}/reply`. The card is removed optimistically *before*
  the network call.
- **Question card** — multi-question, single- or multi-select, optional custom free text
  per question. Builds `List<List<String>>` and calls `store.answerQuestion(q, answers)`
  (`store.dart:1713-1721`), or `rejectQuestion` for Skip.
- On reconnect, `loadPending()` pulls `GET /question` so a request asked while disconnected
  still appears.

---

## 11. FILES / DIFF / TERMINAL — ALL VIA THE UTILITY SESSION

The app never touches the filesystem directly. It shells out through a **hidden session**
titled `__opencode_app_util__` (`store.dart:1468`).

`_utilSession()` (`store.dart:1471-1492`): validate the cached id with `GET /session/{id}`;
if that fails, look for an existing session with that title; else create it. The session is
filtered out of every user-facing list (`home.dart:88`, `sessions_page.dart:186`,
`widgets.dart:673`).

`runShell(command)` (`store.dart:1494-1524`) → `POST /session/{utilId}/shell` with
`agent` (no LLM call). The response is a message with **tool parts**; the exit code is
folded across all parts so **a later success can never mask an earlier failure** (a
half-applied `writeFile` must not report success). **No tool part at all ⇒ exit 127**,
because returning 0 there is exactly what made writes and deletes fail *silently*.

### `writeFile(path, content)` (`store.dart:1526-1564`)
The most safety-critical function in the app:
```
base64(content) → split into 24000-char chunks (ARG_MAX guard)
cmd = mkdir -p <dir> && : > <path>.oc-tmp                 # tmp always created,
                                                            # so an empty file succeeds
      && printf '%s' '<chunk>' >> tmp   (repeated)
      && base64 -d tmp > tmp.oc-out
      && mv tmp.oc-out <path>                              # atomic: the original is
                                                            # replaced only once fully decoded
      && rm -f tmp && test -f <path>
```
`: > $tmp` truncates any leftover temp from a failed write (appending to it used to
prepend garbage to the new content). On failure: best-effort `rm -f` of both temps, then
throw `ApiException('WriteFailed')`.

`_shellQuote` (`:1573-1580`) escapes `'` → `'\''` and **rejects** newlines and NUL bytes.
`_parentDir` returns `/` when there is none.

### Files screen (`lib/ui/files_page.dart`)
- lists `GET /file?path=<dir>`, directories first then case-insensitive name sort (`:150-187`)
- `fileStatus()` supplies the modified-file count
- `_normDir` (`:49-61`): project root is `.`, `./` prefix stripped, trailing `/` stripped,
  empty never reaches the API as `''` (which used to break loading outright)
- breadcrumbs are built from the normalised dir, so `/storage/...` is not prefixed with `.`
- long-press menu: **Rename** (`mv`), **Duplicate** (`cp -r`), **New subfolder**
  (`store.mkdirEntry`), **Send to chat** (`store.send('@<path> review this file')`),
  **Delete** (confirm → `store.deleteEntry`)
- `FileEditorPage` (`:607+`) reads via `store.api.readFile`, flags binary by a NUL byte
  (`:657`), warns on exit via `PopScope` when dirty, saves via `store.writeFile`
- **No storage permission prompt** — deliberate (`store.dart:398-401`, `:1526-1530`)

### Diff screen (`lib/ui/diff_page.dart`)
Two sources: **session** (`GET /session/{id}/diff` → per-file additions/deletions) and
**git** (`GET /vcs/diff?mode=worktree|staged|all` + `GET /vcs/status`). `_diffOps` /
`_toGitPatch` (`:358-406`) build a unified diff and `_GitDiffView` renders it line by line
with add/del colouring.

### Terminal (`lib/ui/terminal_page.dart`)
Same `store.runShell`. Command history with up/down recall, 11 shortcut commands
(`pwd`, `ls`, `git status`, `git diff`, `tree`, …), wrap toggle. `clear` is handled
**locally** because `clear` only works with a PTY attached (`terminal_page.dart:72-97`).

---

## 12. SESSIONS — full lifecycle

| Action | Store method | Server |
|---|---|---|
| List | `refreshSessions` `:725` | `GET /session`, sorted by `updated` desc, persisted to DB |
| Create | `newSession` `:782` | `POST /session` (with title/agent/model), then refresh + open |
| Open | `openSession` `:800` | see §8 |
| Rename | `renameSession` `:868` | `PATCH /session/{id}` |
| Delete | `deleteSession` `:877` | `DELETE /session/{id}` + wipe DB rows |
| Fork | `forkSession` `:895` | `POST /session/{id}/fork` (`messageID` optional) |
| Share | `shareSession` / `unshareSession` `:906/916` | `POST` / `DELETE /session/{id}/share` |
| Abort | `abortSession` `:925` | `POST /session/{id}/abort`, then `_settleStuckStreaming()` |
| Compact | `summarize` `:1406` | `POST /session/{id}/summarize` |
| Undo / Redo | `revert` / `unrevert` `:1416/1427` | `POST …/revert`, `POST …/unrevert`, then `openSession` |
| Init agents | `initAgents` `:1438` | `POST /session/{id}/init` with the last user message id |

`summary == true` messages (compaction summaries) are filtered out of the transcript
everywhere (`store.dart:342, 630, 829`). This is strict: only a **literal** `true` counts,
because a user message can carry a `summary` *object* and treating that as a summary made
user messages vanish after a reload (`models.dart:186-190`).

**Sessions screen** (`sessions_page.dart`): live search box (label / agent / model),
parents-only filter, rows grouped by date bucket with sticky headers, **swipe-to-delete
that deletes immediately and then offers undo** (creating a new session with the old title)
rather than confirming twice, 72 dp rows, 3 px accent rail on the active row, and an
error-guarded row wrapper so one corrupt session cannot break the list (`:308-374`).
Tapping a row: `openSession` then `push(ChatPage)`.

**Message-level actions** (long-press, `chat.dart:1433-1506`): Copy · Fork here ·
Undo (assistant only) · Delete. Delete uses `showUndoSnack` and the undo bar honestly says
the recovery is "revert this message" because the server has no restore endpoint.

---

## 13. NOTIFICATION STRATEGY — why there are TWO notifiers

This is a deliberate performance architecture, not an accident.

`OcStore extends ChangeNotifier` (app-wide) **plus** a second `MessageListSignal extends
ChangeNotifier` (`store.dart:68-74`) that only the transcript listens to.

Why: token streaming rewrites `messages` many times a second. Firing the app-wide
notifier that often rebuilt **every** mounted subscriber — the composer, the sessions tab
kept alive in the `IndexedStack`, the busy and error bars — even though only the transcript
displays the text (`store.dart:59-67`).

- `messageList` → transcript rebuild only (`_scheduleMessageNotify`, 60 ms throttle)
- the app-wide notifier → everything else (`_scheduleNotify`, 60 ms throttle)
- `messageListenable = Listenable.merge([this, messageList])` (`store.dart:91-94`) — built
  **once** because `Listenable.merge` re-subscribes on every construction. The merge is what
  makes the split safe: any mutation that still notifies the app also refreshes the
  transcript, so **no update path can silently leave the list stale.**

Throttling detail (`store.dart:183-208`): the **first** change of a burst paints
immediately, then a 60 ms window coalesces the rest, and a trailing rebuild is guaranteed
so the final token of a turn is never left unrendered.

Per-widget subscriptions:
| Widget | Listens to |
|---|---|
| `_ChatMessages` | `store.messageListenable` (`chat.dart:439-442`) |
| `_ComposerWidget`, `_ErrorBarWidget`, `_BusyBarWidget` | `AppScope.of(context)` (the store) |
| `_MessageTile` | nothing — it re-renders when the list rebuilds, and caches on a signature |

`_MessageTile` (`chat.dart:1146-1178`) computes an `Object.hash` signature over
`(identityHashCode(info), parts.length, hash of part identities, errorText, isLastReply,
showTokens)` and returns a cached `RepaintBoundary`. Without it, every store update re-parsed
the markdown of **every** message. `didChangeDependencies` invalidates the cache when the
theme or screen size changes.

`AppScope.of(context)` vs `AppScope.read(context)` (`app_scope.dart:10-21`): `of`
subscribes (use in `build`), `read` does not (use in callbacks — where
`dependOnInheritedWidgetOfExactType` is illegal or wasteful).

---

## 14. CHAT SCREEN MECHANICS (`lib/ui/chat.dart`)

### Follow-the-tail (one owner, no disagreement)
All of it lives in `_ChatPageState` (`chat.dart:34-286`), because two independent `_stick`
flags used to disagree.

| Field | Meaning |
|---|---|
| `_stickSlop = 80` | gap still counted as "following" |
| `_jumpThreshold = 220` | gap past which the jump button appears (hysteresis prevents flicker) |
| `_follow` | user has not scrolled away from the tail |
| `_dragging` | a finger is on the list — auto-scroll must not touch the controller at all |
| `_programmatic` | we are moving the scroll ourselves, so the listener ignores it |
| `_scrollQueued` | at most one post-frame scroll per frame, no matter how many tokens land |

Rules:
- `jumpTo`, **never** `animateTo`, for auto-scroll (`_runAutoScroll`, `:201-209`): an
  animation started per token stacks into a fight with the user's finger.
- Grabbing the list **always** releases follow mode (`_handleNotification`, `:154-175`);
  dragging back down within the slop **re-arms** it. Flings and keyboard scrolls carry no
  `dragDetails` and are treated as intent via `UserScrollNotification` at `depth == 0`.
- Re-arming key is the **tail message id**, not the count: prepending an older page also
  raises the count and used to yank the reader to the bottom mid-history (`_syncFollow`,
  `:264-273`).
- Load-completion re-arms follow only if already following, or if it was the initial load.
- `_unread` counts off-screen arrivals; **only reaching the bottom clears it**, so the badge
  can never disagree with what is visible.
- The listener is detached in `dispose` and the store is cached in a field `_store`
  (`chat.dart:74-78`): looking it up through the context during `dispose` is illegal and
  leaks the listener.

### Composer
- placeholder changes between "start" and "reply" so an active conversation does not look
  like a cold start (`chat.dart:1750-1752`)
- send button: Stop while busy → Send when there is text or an attachment → Mic otherwise
  (voice is a placeholder; tapping shows a tooltip) — all three 48 dp
- **attach sheet**: Image (gallery → base64 data URL) · Project file (server-side file picker
  → base64 of content) · Slash command (inserts into the field). MIME is inferred by
  extension, defaulting to `text/plain` (`chat.dart:1885-1898`)
- `_showAttachSheet` has a **titled** header so three bare rows are not read as page content

### Slash / @ autocomplete — `SlashTextField` (`chat.dart:2356-2569`)
Listens to both the controller and the focus node, then regex-matches **up to the caret**:
- `(?:^|\s)/([\w-]*)$` → command suggestions (server commands + builtins
  `init, compact, undo, redo, share, clear`), max 8
- `(?:^|\s)@([\w./-]*)$` → `@file` search via `store.api.findFiles(q, limit: 8)`, **debounced
  250 ms**
The suggestion list renders **above** the tools row, so accepting a completion never resizes
the composer's bottom edge.

### Empty state — `_Welcome` (`chat.dart:686-1029`)
hero title → `_ModelModeChips` (agent + model) → `_ProjectBar` (server paths/branch) →
4 `SuggestionCard`s. Pinned top *and* bottom by `IntrinsicHeight` + `ConstrainedBox(minHeight: viewport)`
inside a `SingleChildScrollView`. `SuggestionCard` and `OutlinedChip` are **public** so the
hero and the composer share one implementation.

Suggestion cards **send immediately** (`_sendSuggestion`, `:321-328`). Dropping the text
into the field first made the composer grow and the keyboard pop, losing the user's place.

### Transcript list
- skeleton (`OCSkeletonList`) rather than a spinner while loading — same shape, so the page
  does not jump (`chat.dart:448-453`)
- custom `Scrollbar`, `thumbVisibility: false` so a non-overflowing list shows no bar; the
  left-edge bar users reported was the platform overlay drawing outside the layout
  (`chat.dart:475-495`)
- token/cost footer (`_ReplyMeta`) hidden unless `store.showTokensInChat`; the footer
  belongs to the **last assistant reply only** (`chat.dart:460-466, 1317`)

---

## 15. MESSAGE PART RENDERING (`lib/ui/parts.dart`)

`PartTile` is a `switch` on `part.type` (`parts.dart:237-329`):
`text` → Markdown · `reasoning` → collapsible · `tool` → `ToolTile` · `file` → chip ·
`patch` → collapsible + `DiffText` · `subtask` → collapsible · `agent` → `_AgentPart` ·
`retry` → `_RetryPart` · `compaction` → orange "context compacted" notice ·
`snapshot` → nothing · anything else → `_UnknownPart`.

`ToolTimeline` (`:26-229`) splits parts into **tools** (a compact vertical timeline) and
**the rest** (thinking group + tiles):
- a 10 px status dot on a 2 px rail: accent while running, green completed, red error,
  muted pending
- line = bold tool name + monospace `summary · duration · exit N · truncated`, ellipsised
- tap expands `_InputBlock` (tool JSON) and `_OutputBlock` (stdout/stderr)
- **consecutive `reasoning` parts collapse into one `ThinkingGroup`** — rendered
  individually they pushed the actual answer off screen and read like a wall of italic text

`Part.summaryLine` (`models.dart:311-334`) derives a human one-liner per tool:
`bash/shell` → command · `read/write/edit/patch` → file path · `grep`/`glob` → pattern ·
`list` → path · `webfetch/websearch` → url/query · `task/agent` → subagent type.

**Assistant message layout** (`chat.dart:1287-1324`): `ToolTimeline` (non-text parts) →
Markdown text → typing dots (only while streaming **and** with nothing to show yet) →
inline error → token footer → inline actions (last reply only).

---

## 16. DESIGN SYSTEM

`lib/ui/theme.dart`: `OCColors` (raw palette) → `OCTokens` (`ThemeExtension`, semantic:
`bg`, `card`, `surfaceElevated`, `ink`, `mute`, `line`, `acc`, `accSoft`, `ok`, `err`,
`errSoft`, `warn`) → `OCSpace` (incl. **`OCSpace.screenGutter`, the one horizontal inset**),
`OCRadius`, `OCMotion`, `OCTypography`. `buildAppTheme()` → `ThemeData`.

`ThemeMode.dark` is **hardcoded** (`main.dart:66`). `ThemeMode.system` was what let a light
`ThemeData` paint white cards and sheets into an otherwise dark app.

`lib/ui/primitives.dart`: 22 `OC*` widgets. Highest-fanout nodes (riskiest to edit, per the
code graph): `OCIconTile` (12 links), `OCButton` (11), `OCStatus`, `OCAvatar`/`OCAvatarStack`,
`OCToggle`, `OCSegmentedControl`, `OCProgressRing`, `OCProgressBar`, `OCChip`, `OCListRow`,
`OCBreadcrumbs`, `OCFilterButton`, `OCSkeletonList`.

`ocReduceMotion()` (`widgets.dart:484-490`) — **every** looping or scale animation must go
through it; it reads the OS "remove animations" setting.

Naming/role conventions worth preserving: `OCSpace.screenGutter` is the single horizontal
inset (`screenX` is the older 16 dp alias), `OCRadius.suggestion` / `.composer`,
`OCMotion.pressScaleSoft`, `OCTypography.heroTitle` / `.meta`, `OCTokens.surfaceElevated` for
the composer and `.warn` for the reconnecting state.

**Icons are drawn in code**, not from a font: enum `LI` (`line_icons.dart:17`), `LIcon`
widget (`:99`), `LLinePainter` (`:189`) with a per-icon path switch (`:230-644`).

**Markdown is hand-written** (`lib/ui/markdown.dart`): text → `_Block` list (paragraph, list,
table, code, heading) → widgets, with a global `_parseCache` (`:377`). Supports links, inline
code, bold/italic, tables, fenced code. Links open externally via `url_launcher`.

**Strings**: class `S` in `lib/l10n/strings.dart`. Rule at `strings.dart:1-7`: **no string
literals inside widgets.** (A few legacy exceptions remain — e.g. the question card title
"Agent ne sawal pucha" at `prompts.dart:203` and the `_PermissionCard` "Baaki N request(s)
pending" at `prompts.dart:133` — these are inconsistent with the rule and should move to `S`.)

---

## 17. ERROR MODEL

`ApiException(status, name, message)` (`client.dart:13-24`), with `isAuth` (401/403) and
`isNotFound` (404).

`_sendOnce` (`client.dart:121-158`) maps **every** transport failure onto it:
| Dart exception | `name` |
|---|---|
| `TimeoutException` | `Timeout` (message `S.netTimeout(seconds)`) |
| `SocketException` | `NoConnection` (`S.netUnreachable(root)`) |
| `TlsException` | `BadProtocol` — **listed before** `HandshakeException` because it is a subtype |
| `HandshakeException` | `BadProtocol` (https against a plain http server) |
| `http.ClientException` | `Network` |
| `FormatException` | `BadResponse` |

`_decode` (`client.dart:78-120`) turns the server's `{name, data}` error envelope into an
`ApiException`. Bodies **> 32 KB** and status < 400 are JSON-parsed in a **background
isolate** (`compute`) so a big history never freezes the UI (`_isolateThreshold`,
`client.dart:31`). `utf8.decode(allowMalformed: true)` everywhere — never a hard failure.

`_send` (`client.dart:169-183`) buys **one** transparent retry for `idempotent: true` calls
(i.e. `get`) when the failure is `NoConnection`/`Network`: this client pools keep-alive
sockets and a Termux restart closes them while they sit in the pool, so the next request
would fail on an already-dead socket and **every** call after a server restart would fail
until the pool aged out. Reads are safe to repeat. **Not** retried on timeout — a 30 s agent
turn must not silently become 60 s.

Timeouts: default 30 s; `deleteSession`/`abort`/`share`/`deleteMessage` 2 min; `init`/
`summarize` 10 min; `prompt`/`runCommand` 30 min; `shell` 10 min; `promptAsync` 60 s;
`upgrade` 5 min; `setApiKey` 2 min. Pooled `HttpClient`: `connectionTimeout` 10 s,
`idleTimeout` 2 min (`client.dart:46-50`).

**UI feedback helpers** (`widgets.dart`):
- `showToast` / `showSnack` — an `OverlayEntry` (not a `SnackBar`), so it works inside
  dialogs and sheets without stealing focus; auto-dismiss 3 s
- `showUndoSnack` — a real `SnackBar` (it needs the action slot) for reversible deletes
- `copyToClipboard`, `promptText`, `confirmDialog`, `showToast`
- `OcStore._toast(m)` stores a one-shot string that the UI drains via `takeToast()`
  (`store.dart:2107-2113`)

---

## 18. SETTINGS & CONFIGURATION

`lib/ui/settings_page.dart`:
- **Server**: URL / user / password (`_editServer` → `store.setServer` → `_persist` +
  `connect`), Reconnect, plus read-only rows for project dir, worktree, config dir, git branch
- **Current session**: Init agents · Summarize · Revert last · Unrevert
- **Providers** (`_Providers`, `:464`): connected list with Logout
  (`api.removeAuth`), and unconnected providers that need a key with an "API key daalo"
  action → `api.setApiKey` (`PUT /auth/{provider}`) → `refreshCatalog`
- **Raw config editor** (`_ConfigEditor`, `:575+`) → `store.saveConfig(patch)` (`PATCH /config`)
- **MCP**: add local or remote server (`store.addMcp`), connect/disconnect
- `enableExternalDirectoryAccess()` (`store.dart:1641`) patches
  `permission: {edit, bash, external_directory: "allow"}` — the one-tap fix for tools
  complaining about directories outside the workspace

**Model/agent selection** (`models_page.dart`): search box, provider filter chips,
"connected only" toggle; `ProviderInfo.ordered` (`client.dart:782-792`) sorts connected
providers first and drops providers with no models. If no provider/model is persisted,
`refreshCatalog` (`store.dart:671-690`) auto-picks the first connected provider's default
model. Agent dropdown writes `store.setAgent`. Tools sheet fetches
`GET /experimental/tool/ids` and toggles into `toolsEnabled`, sent as `tools: {id: true}`
only when non-empty (`toolMap`, `store.dart:718-719`).

---

## 19. BUILD & DEPLOY

`deploy.py` → `git add -A` → commit → push to `main` on the configured remote.
`.github/workflows/build.yml` then:
1. checkout, Java 17, Flutter stable (cached)
2. **`flutter create . --platforms=android`** — the repo has **no `android/` directory**.
   `pubspec.yaml`, `lib/`, and `analysis_options.yaml` are backed up and restored, and the
   generated `test/` is deleted (the template test references a `MyApp` class that does not
   exist here and would fail analyze)
3. **Manifest patches**: `INTERNET` permission; `android:usesCleartextTraffic="true"`
   (Termux localhost and LAN servers are plain HTTP); label `OpenCode`; storage permissions;
   `REQUEST_INSTALL_PACKAGES`
4. Gradle parallel + caching, then a Gradle cache action keyed on `pubspec.yaml`
5. `flutter pub get`
6. **`flutter analyze --no-fatal-infos --no-fatal-warnings`** — only errors fail the build
7. `flutter build apk --release --target-platform android-arm64` (one APK; use
   `--target-platform android-arm` for 32-bit phones)
8. upload the `opencode-apk` artifact

`setup.sh` (run on the phone in Termux) installs `~/.local/bin/opencode-start` and
`opencode-stop`, optionally registers a Termux:Boot autostart, and health-checks
`/global/health`. It defaults to `PORT=4096`, project dir `~/project`.

**Order matters:** the server must be started from the project directory the app should see —
the file browser, diff and editor all operate on the server's **current directory**.

---

## 20. INVARIANTS — do not break these

1. **The server is the only source of truth.** The cache exists for offline *reading*, never
   for offline *writing*.
2. **Never write a non-cacheable message to disk** (optimistic echo, placeholder, streaming
   assistant). `_isCacheable` is the gate.
3. **Ordering in the cache comes from the server's `created`**, never from write time.
4. **All DB writes go through `_enqueue`.** A direct `db.insert` breaks ordering guarantees.
5. **`_socketIdle` must stay far above any quiet period.** dart:io defaults to 15 s, which
   used to kill the SSE stream every time the agent paused to think.
6. **Silence is not death.** Only a failed `/global/health` probe (or 180 s of silence *while
   busy*) may trigger a reconnect.
7. **`online` is never set from the stream alone.** Only a health probe decides reachability.
8. **Claim the SSE generation before the first `await`** in `_connect`.
9. **Always guard an async load with the generation/id check** (`_historyLoadGen`,
   `current?.id == id`, `_disposed`). The app switches sessions constantly.
10. **Only one prompt in flight.** That is what makes the optimistic echo handover 1:1 and
    lets `_stripEchoedOptimistic` match on content.
11. **Never re-open the session on app resume.** It wipes the on-screen chat.
12. **`inactive` is not backgrounding.** Only `paused`/`detached` pause the stream.
13. **Route token-level updates through `messageList`**, not the app-wide notifier.
14. **No string literals in widgets** — everything goes in class `S`.
15. **Every looping/scale animation goes through `ocReduceMotion()`.**
16. **`ThemeMode.dark` is hardcoded** on purpose.
17. **File writes happen on the server via `writeFile`'s atomic temp+mv** — never a naive
    redirect, never a direct app-side write.
18. **`_shellQuote` rejects newlines and NUL bytes** — never relax that.
19. **`.oc-tmp` files must be cleaned up** on every write path (success and failure).
20. **The util session `__opencode_app_util__` must stay filtered out** of every user-facing list.

---

## 21. RECIPES — how to make common changes

| Task | Do this |
|---|---|
| Add a server endpoint | Add a typed method on `OcClient` (`lib/api/client.dart`). Call it from `OcStore`, not from a widget. |
| Show a new field in chat | Extend `lib/models/models.dart`; render it in `parts.dart` (`PartTile`) or `chat.dart` (`_MessageTile._buildContent`). |
| Add a screen | Create the page, open it with `pushScreen(context, title:, child:)` (`widgets.dart:13`). |
| Add a bottom-sheet row | `_SheetOption` / `_SheetGroup` in `home.dart:652/713`. |
| Add a button primitive | `lib/ui/primitives.dart`; extend `OCButtonVariant` if it is a variant. |
| Add a user-facing string | Add to class `S` in `lib/l10n/strings.dart`. Never inline it. |
| Add an SSE reaction | A `case` in `_handleEvent` (`store.dart:1747`). Decide whether it is session-scoped (`_isCurrent`) or global. |
| Add a cached field | Nothing extra — `_dbRow` stores `info.toMap()` / `p.toMap()`, which are the **raw server JSON**, so a new field round-trips automatically. |
| Add a chat action | Add to `_MessageActions` (`chat.dart:2910`) and/or `showMessageMenu` (`chat.dart:1433`). |
| Change connection policy | `lib/api/events.dart` constants + `OcStore._verifyReachability`. Re-read §3 first. |
| Change the tab set | `HomeShell.tabs` and `_pages` (`home.dart:45-61`). Keep the two lists the same length. |
| Change anything a stream touches | Run `python graphify/graphify_lite.py` afterwards to refresh the code map. |

**Verification:** the only automated check is
`flutter analyze --no-fatal-infos --no-fatal-warnings` (what CI runs). There are **no
tests** — verify by hand against a real Termux server: send a message, stream a long answer,
background the app mid-run, kill the server and watch the status pill, restart the server
and watch it recover.

---

## 22. KNOWN GOTCHAS (things that look wrong but are not)

- `pageLimit = 500` looks absurd for a "recent messages" page. It exists because `before`
  pagination is broken on opencode 1.18.27.
- `if (e == 0 && p.status == ToolStatus.error) code = 1;` in `runShell` looks redundant. It
  is not: a tool-level failure with no `exit` in the metadata still has to fail.
- The composer has a Mic button that does nothing. It is a deliberate placeholder so the
  composer matches the reference layout.
- Some strings are still Hinglish inside `prompts.dart` and a few widgets. Legacy, not intended.
- `SessionSummary` has a `static final zero`. Used as a null-ish default.
- `_PermissionCard` shows a raw count of remaining requests. The count is correct even when
  the queue is not, because the overlay renders `.first` only.
- `AppScope.of` is used in `build` and `AppScope.read` in callbacks. Swapping them causes
  either unnecessary rebuilds or a `dependOnInheritedWidgetOfExactType` assert.
- `_MessageTile` returns a cached `RepaintBoundary`. Adding anything that depends on external
  state to `_buildContent` without adding it to `_signature()` will produce a stale tile.

---

## 23. END-TO-END TRACE — the ten most important calls

```
opencode_chat: user message typed and sent
 1. chat.dart:330   ChatPage._send
 2. store.dart:1107 OcStore.sendOrQueue            (busy → queue)
 3. store.dart:1134 OcStore.send                   (optimistic bubble)
 4. store.dart:1321 OcStore._sendParts             (busy = true)
 5. client.dart:514 POST /session/{id}/prompt_async
 6. events.dart:326 frame → store.dart:1737 handleEvent → store.dart:1750 _handleEvent
 7. store.dart:1750 message.updated / 1755 part.updated / 1759 part.delta
 8. store.dart:2038 _applyDelta                   (token appended in place)
 9. store.dart:183  _scheduleFlush (400 ms) → chat_db.dart:132 upsertMessages
10. events.dart:387 session.idle → store.dart:1786 busy = false, flush queue, refresh todos/diff/sessions
```
