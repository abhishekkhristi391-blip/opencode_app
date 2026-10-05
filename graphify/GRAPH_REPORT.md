# GRAPH REPORT
27 files, 711 symbols, 1243 edges (846 EXTRACTED, 397 INFERRED)

## God nodes (most connected = riskiest to edit)
- OCIconTile (class) - 12 links - lib/ui/primitives.dart:473
- mono (function) - 12 links - lib/ui/theme.dart:913
- OCButton (class) - 11 links - lib/ui/primitives.dart:110
- showSnack (function) - 10 links - lib/ui/widgets.dart:134
- read (function) - 9 links - lib/ui/app_scope.dart:17
- EmptyHint (class) - 9 links - lib/ui/widgets.dart:162
- clear (function) - 7 links - lib/ui/terminal_page.dart:42
- LoadingView (class) - 7 links - lib/ui/widgets.dart:221
- asMap (function) - 6 links - lib/models/models.dart:5
- LIcon (class) - 6 links - lib/ui/line_icons.dart:170

## Communities (modules that talk to each other)
1. 26 files: lib/api/client.dart, lib/api/events.dart, lib/db/chat_db.dart, lib/l10n/strings.dart, lib/main.dart ...

## Folder dependencies (who imports whom)
- lib/ui -> lib/l10n  (15 imports)
- lib/ui -> lib/models  (12 imports)
- lib/ui -> lib/state  (11 imports)
- lib -> lib/ui  (3 imports)
- lib/api -> lib/models  (2 imports)
- lib/state -> lib/api  (2 imports)
- lib/ui -> lib/api  (2 imports)
- lib/api -> lib/l10n  (1 imports)
- lib -> lib/state  (1 imports)
- lib/state -> lib/l10n  (1 imports)

## Circular imports (real import cycles only)
- lib/ui/chat.dart <-> lib/ui/models_page.dart

## Orphan files (nobody imports them: dead code?)
- deploy.py

## Issues / suspicious spots
- none

## Rationale / TODO notes
- WHY: the raw message needs this before the UI can show anything. - lib/models/models.dart:189
- NOTE: there is deliberately no storage-permission gate here. File writes go - lib/state/store.dart:399

## Suggested questions
- What breaks if I change OCIconTile?   -> impact
- How does OCIconTile connect to <your module>?   -> path
- Which files depend on the most-connected file?   -> explain

NOTE: INFERRED edges are name-matches. Verify before trusting.
