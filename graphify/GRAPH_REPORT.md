# GRAPH REPORT
26 files, 567 symbols, 994 edges (677 EXTRACTED, 317 INFERRED)

## God nodes (most connected = riskiest to edit)
- OCIconTile (class) - 12 links - lib/ui/primitives.dart:464
- mono (function) - 12 links - lib/ui/theme.dart:544
- OCButton (class) - 10 links - lib/ui/primitives.dart:98
- read (function) - 9 links - lib/main.dart:84
- showSnack (function) - 9 links - lib/ui/widgets.dart:132
- EmptyHint (class) - 9 links - lib/ui/widgets.dart:147
- LoadingView (class) - 7 links - lib/ui/widgets.dart:206
- send (function) - 6 links - lib/state/store.dart:809
- confirmDialog (function) - 6 links - lib/ui/widgets.dart:370
- SectionTitle (class) - 6 links - lib/ui/widgets.dart:405

## Communities (modules that talk to each other)
1. 25 files: lib/api/client.dart, lib/api/events.dart, lib/db/chat_db.dart, lib/l10n/strings.dart, lib/main.dart ...

## Folder dependencies (who imports whom)
- lib/ui -> lib  (12 imports)
- lib/ui -> lib/models  (11 imports)
- lib/ui -> lib/l10n  (5 imports)
- lib/ui -> lib/state  (4 imports)
- lib/api -> lib/models  (2 imports)
- lib -> lib/ui  (2 imports)
- lib/state -> lib/api  (2 imports)
- lib/ui -> lib/api  (2 imports)
- lib -> lib/state  (1 imports)
- lib/state -> lib/models  (1 imports)

## Circular imports (real import cycles only)
- lib/main.dart <-> lib/ui/about_page.dart <-> lib/ui/chat.dart <-> lib/ui/commands_page.dart <-> lib/ui/diff_page.dart

## Orphan files (nobody imports them: dead code?)
- deploy.py

## Issues / suspicious spots
- [WARNING] exception swallowed with 'pass' - deploy.py:83
- [WARNING] empty catch block - lib/api/client.dart:255
- [WARNING] empty catch block - lib/api/client.dart:272
- [WARNING] empty catch block - lib/state/store.dart:261
- [WARNING] empty catch block - lib/state/store.dart:1528
- [WARNING] empty catch block - lib/state/store.dart:1538
- [WARNING] empty catch block - lib/ui/diff_page.dart:62

## Rationale / TODO notes

## Suggested questions
- What breaks if I change OCIconTile?   -> impact
- How does OCIconTile connect to <your module>?   -> path
- Which files depend on the most-connected file?   -> explain

NOTE: INFERRED edges are name-matches. Verify before trusting.
