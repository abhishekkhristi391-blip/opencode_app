# GRAPH REPORT
27 files, 584 symbols, 1022 edges (702 EXTRACTED, 320 INFERRED)

## God nodes (most connected = riskiest to edit)
- OCIconTile (class) - 12 links - lib/ui/primitives.dart:464
- mono (function) - 12 links - lib/ui/theme.dart:544
- OCButton (class) - 11 links - lib/ui/primitives.dart:98
- read (function) - 9 links - lib/ui/app_scope.dart:17
- showSnack (function) - 9 links - lib/ui/widgets.dart:132
- EmptyHint (class) - 9 links - lib/ui/widgets.dart:147
- LoadingView (class) - 7 links - lib/ui/widgets.dart:206
- send (function) - 6 links - lib/state/store.dart:966
- confirmDialog (function) - 6 links - lib/ui/widgets.dart:370
- SectionTitle (class) - 6 links - lib/ui/widgets.dart:405

## Communities (modules that talk to each other)
1. 26 files: lib/api/client.dart, lib/api/events.dart, lib/db/chat_db.dart, lib/l10n/strings.dart, lib/main.dart ...

## Folder dependencies (who imports whom)
- lib/ui -> lib/models  (11 imports)
- lib/ui -> lib/state  (10 imports)
- lib/ui -> lib/l10n  (5 imports)
- lib -> lib/ui  (3 imports)
- lib/api -> lib/models  (2 imports)
- lib/state -> lib/api  (2 imports)
- lib/ui -> lib/api  (2 imports)
- lib -> lib/state  (1 imports)
- lib/state -> lib/models  (1 imports)
- lib/state -> lib/db  (1 imports)

## Circular imports (real import cycles only)
- none found

## Orphan files (nobody imports them: dead code?)
- deploy.py

## Issues / suspicious spots
- none

## Rationale / TODO notes
- WHY: the raw message needs this before the UI can show anything. - lib/models/models.dart:189
- NOTE: there is deliberately no storage-permission gate here. File writes go - lib/state/store.dart:393

## Suggested questions
- What breaks if I change OCIconTile?   -> impact
- How does OCIconTile connect to <your module>?   -> path
- Which files depend on the most-connected file?   -> explain

NOTE: INFERRED edges are name-matches. Verify before trusting.
