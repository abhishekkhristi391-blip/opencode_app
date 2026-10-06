# Architecture

Flutter client for an **opencode** server. Talks to a local/remote opencode HTTP
API plus an SSE event stream, renders chat with tool calls, diffs and voice.

> Full historical detail: `ARCHITECTURE_FULL.md`. Line-level map: `graphify/`.

## Layers

```
lib/main.dart            OpenCodeApp, theme, VoiceScope, lifecycle
lib/api/                 HTTP + SSE: client.dart (OcClient), events.dart (EventStream)
lib/state/store.dart     OcStore: the single app-wide ChangeNotifier
lib/db/chat_db.dart      sqflite cache of messages + sessions
lib/models/models.dart   wire types: Message, Part, Session, ModelInfo, Todo...
lib/l10n/strings.dart    class S - every user-facing string
lib/voice/               dictation (STT), read-aloud (TTS), hands-free loop
lib/ui/                  widgets. primitives/ theme/ widgets/ are the design system
```

Dependency direction is one-way: `ui -> state -> api -> models`. Nothing in
`lib/api`, `lib/models`, `lib/db` or `lib/l10n` imports `lib/ui`.

## Data flow

**Send.** Composer -> `store.send()` -> `OcClient.promptAsync()` POSTs
`/session/:id/message` -> server streams back over SSE -> `EventStream` parses
frames -> `OcStore.handleEvent()` upserts Message/Part into `messages` and fires
notifiers -> transcript rebuilds.

**Listen.** `OcStore.messageListenable` merges two notifiers on purpose:
`messageList` for token-level part edits (cheap, transcript-only) and the
`OcStore` itself for app-wide state (session switch, loading, `hasMoreMessages`).
That merge is why a `todo.updated` event does not rebuild the transcript.

**Reconnect.** `EventStream` distinguishes *suspect* from *dead*: silence past
`_staleAfter` (90 s) only schedules a health probe; silence past
`_staleWhileBusy` (180 s) **while a run is in flight** tears the socket down,
because a real run always produces events.

## File layout: barrels + `part`

Large files are **parent barrels**. The parent keeps every `import` and the class
declarations; behaviour lives in `<parent_dir>/<parent_name>/*.dart` children that
open with `part of '../<parent>.dart';`.

```dart
// lib/ui/chat.dart          <- imports + 14 part directives
part 'chat/chat_page.dart';
part 'chat/chat_composer.dart';   // ... 12 more
```

This is a `part` library, **not** an `export` barrel: public API is unchanged
because everything stays in one library, so private `_` helpers keep working and
no call site needs a new import.

| Barrel | Parts | Largest |
|---|---|---|
| `ui/chat.dart` | 14 | 394 |
| `state/store.dart` | 12 | 328 |
| `voice/voice_service.dart` | 8 | 266 |
| `api/client.dart` | 7 | 209 |
| `ui/home.dart`, `ui/primitives.dart`, `ui/theme.dart` | 4 each | 405-651 |
| `ui/settings_page.dart` | 3 | 491 |
| `ui/parts.dart`, `ui/widgets.dart` | 3 each | ~410 |
| `ui/files_page.dart`, `ui/markdown.dart`, `ui/prompts.dart`, `ui/sessions_page.dart`, `models/models.dart` | 2 each | 383-459 |

### `extension X on Y` for the three god classes

`OcStore` (91 members), `OcClient` (38) and `VoiceService` (79) are too big for
one file, and a Dart **class body cannot span `part` files**. So each keeps its
fields and statics in the class and moves its methods into per-topic extensions:

```
state/store/store_ocstore.dart            fields, statics, dispose()
state/store/store_ocstore_connection.dart extension OcStoreConnection on OcStore
state/store/store_ocstore_sessions.dart   extension OcStoreSessions   on OcStore
... 8 more
```

Two rules that are easy to get wrong:

1. **Extension members resolve only where the declaring library is imported.**
   `AppScope.of(context)` hands you an `OcStore`, but `store.connect()` will not
   compile unless the file also does `import '../state/store.dart';`. Same for
   `api.<method>()` -> `import '../api/client.dart';`.
2. **Never name an extension member the same as a class member.** The class
   member wins silently, so the moved code simply stops being called. No error.

Private `_` members, `notifyListeners()` and `super.dispose()` all still work —
extensions share the library.

## Design system

`ui/theme` owns tokens (`OCTokens`, `OCColors`, `OCTypography`, `OCRadius`) and
`buildAppTheme()`. `ui/primitives` owns the reusable controls (`OCButton`,
`OCCard`, `OCIconTile`, `OCListRow`, `OCProgressBar`, `OCChip`, ...). Screens are
built from these, not raw `Material` widgets, so a theme change lands everywhere.
`ui/line_icons` is a hand-drawn `CustomPainter` icon set (no icon font).

## Conventions

- Access state via `AppScope.read(context)` / `AppScope.of(context)`; never
  `Provider`. Voice the same way through `VoiceScope`.
- Strings always come from `S` (`lib/l10n/strings.dart`). No inline user-facing text.
- Loading/empty/error states use `LoadingView`, `EmptyHint`,
  `ConnectionErrorView`, `showSnack`, `pushScreen` from `ui/widgets`.
- Ask before re-adding the active permission/question overlay: `ui/prompts`
  renders it above everything, over the composer.

## Gotchas

- `lib/l10n/strings.dart` (1154) and `ui/line_icons/line_icons_painter.dart` (934)
  are single declarations; splitting either needs a logic change, so they stay.
- Tool runs stream as `Part` updates; a tool that never reports `running` has a
  liveness probe behind it (`_probeBusyState`).