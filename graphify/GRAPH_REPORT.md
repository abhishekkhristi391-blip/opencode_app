# GRAPH REPORT
103 files, 932 symbols, 1901 edges (1089 EXTRACTED, 812 INFERRED)

## God nodes (most connected = riskiest to edit)
- LIcon (class) - 22 links - lib/ui/line_icons/line_icons_widgets.dart:158
- read (function) - 19 links - lib/ui/app_scope.dart:17
- read (function) - 19 links - lib/voice/voice_scope.dart:26
- OCIconTile (class) - 18 links - lib/ui/primitives/primitives_cells_controls.dart:58
- mono (function) - 18 links - lib/ui/theme/theme_radius_typography.dart:284
- showSnack (function) - 18 links - lib/ui/widgets/widgets_navigation_feedback.dart:131
- asMap (function) - 16 links - lib/models/models/models_session_message.dart:3
- OCButton (class) - 13 links - lib/ui/primitives/primitives_buttons_cards.dart:94

## Communities (modules that talk to each other)
1. 28 files: lib/api/client.dart, lib/api/events.dart, lib/db/chat_db.dart, lib/l10n/strings.dart, lib/main.dart ...

## Folder dependencies (who imports whom)
- lib/ui -> lib/l10n  (15 imports)
- lib/ui -> lib/state  (14 imports)
- lib/ui -> lib/models  (12 imports)
- lib -> lib/ui  (4 imports)
- lib/ui -> lib/voice  (4 imports)
- lib/ui -> lib/api  (3 imports)
- lib/api -> lib/models  (2 imports)
- lib -> lib/voice  (2 imports)
- lib/state -> lib/api  (2 imports)
- lib/api -> lib/l10n  (1 imports)

## Circular imports (real import cycles only)
- lib/ui/chat.dart <-> lib/ui/models_page.dart

## Orphan files (nobody imports them: dead code?)
- deploy.py
- lib/models/models/models_session_message.dart
- lib/state/store/store_ocstore.dart
- lib/state/store/store_ocstore_cache.dart
- lib/state/store/store_ocstore_connection.dart
- lib/state/store/store_ocstore_events.dart
- lib/state/store/store_ocstore_history.dart
- lib/state/store/store_ocstore_messages.dart
- lib/state/store/store_ocstore_prompts.dart
- lib/state/store/store_ocstore_run.dart
- lib/state/store/store_ocstore_sessions.dart
- lib/state/store/store_ocstore_view_state.dart
- lib/state/store/store_ocstore_workspace.dart
- lib/state/store/store_types.dart
- lib/ui/chat/chat_agent_sheets.dart

## Issues / suspicious spots
- none

## Rationale / TODO notes
- WHY: the raw message needs this before the UI can show anything. - lib/models/models/models_session_message.dart:218
- NOTE: there is deliberately no storage-permission gate here. File writes go - lib/state/store/store_ocstore_connection.dart:16
- TODO: updates that landed while the socket was down are gone with it, and - lib/state/store/store_ocstore_connection.dart:286
- WHY: * the agent is quiet. A pending - lib/ui/chat/chat_run_progress.dart:9
- WHY: hands-free or dictation stopped gets one snackbar, not a banner that - lib/ui/chat/chat_voice_strip.dart:42
- WHY: the last attempt stopped, if it stopped badly. - lib/voice/voice_service/voice_service_state.dart:12
- WHY: hands-free turned itself off. The UI shows it once, then calls - lib/voice/voice_service/voice_service_state.dart:15
- WHY: voice stopped, in terms the UI turns into one calm sentence. - lib/voice/voice_service/voice_service_types.dart:51

## Suggested questions
- What breaks if I change LIcon?   -> impact
- How does LIcon connect to <your module>?   -> path
- Which files depend on the most-connected file?   -> explain

NOTE: INFERRED edges are name-matches. Verify before trusting.
