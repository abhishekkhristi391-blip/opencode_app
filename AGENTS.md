<!-- graphify:start -->
## graphify (code map of this project) - READ THIS FIRST
`graphify/GRAPH_REPORT.md` and `graphify/FILES.md` are the map of this project (preloaded in context; if you do not see them, read them once).
- The map already says which file/function holds what, with exact line ranges. Go STRAIGHT to those files and read ONLY those line ranges (offset/limit). Do not re-read the map, do not explore.
- Do NOT grep or `find` the whole project. NEVER run `find` on `/`, `/storage`, `/data` or outside the project folder.
- Use as few tool calls as possible: map -> exact line ranges -> answer/edit.
- AFTER you edit code files run `python graphify/graphify_lite.py` (ONE command: refreshes the map only if code changed).
- EXTRACTED links are facts, INFERRED are guesses (verify). Cite `file:line`.
- More: `graphify/AGENT_GUIDE.md`.
<!-- graphify:end -->

## Concurrent sessions — never sweep other agents' work into your commit
Another agent session may be editing files at the same time. Never stage files you did not change. Always pass explicit paths to deploy.py. Never touch lib/voice/ unless your task is the voice work.
- `python deploy.py "message" path1 path2 ...` is the only supported form. It stages exactly those paths, prints the staged list, and aborts if the index holds anything else. There is no "commit everything" fallback.
- Before deploying, run `git status --porcelain` and confirm every modified file is one you wrote. If a file you did not touch is dirty, another session owns it — leave it alone and do not include it.

## File layout: barrels are `part` libraries, not exports
Every big file is a **parent barrel** that owns the `import`s and lists `part '<dir>/<name>.dart';`. Children start with `part of '../<parent>.dart';`.
- The parent is NOT an `export` barrel. Public API is unchanged because the classes stay in the parent library; do not convert these to `export` or the private `_` symbols break.
- Parent `part` paths are **relative to the parent**, not repo-root. `part 'chat/chat_page.dart';` inside `lib/ui/chat.dart` is correct; `part 'lib/ui/chat/chat_page.dart';` is the bug that shipped once and broke every part into a standalone library.
- Naming: `lib/ui/chat/chat_page.dart` for parent `lib/ui/chat.dart`. Same prefix as the parent file.
- Before adding a part by hand, run `dart format -o none <parent> <child>` and confirm the directive points at a file that exists.

## The one trap: extension members need a direct import
`OcStore`, `OcClient` and `VoiceService` keep their **fields in the class** and their **behaviour in `extension X on Y { }`** parts (`lib/state/store/store_ocstore_*.dart`, `lib/api/client/client_oc_client_*.dart`, `lib/voice/voice_service/voice_service_*.dart`). A Dart class body cannot span `part` files, so extensions are the only way to keep those files small.

An extension member is resolved **only in libraries that import the library declaring the extension**. Getting the *type* transitively is not enough:
```dart
// lib/ui/some_page.dart  — has the OcStore TYPE via AppScope.of(context),
// but `store.connect()` will NOT resolve until it imports the barrel itself.
import '../state/store.dart';   // REQUIRED for OcStore extension members
import '../api/client.dart';   // REQUIRED for OcClient extension members (api.toolIds() etc)
```
So: **any new file that calls `store.<method>()` or `api.<method>()` must import `../state/store.dart` / `../api/client.dart` directly.** All 8 pages that needed this were fixed in `0c44118` and `61bcd43`; a 9th will fail CI the same way.

Two related rules for those extensions:
- An extension member whose name equals a class member is **silently shadowed** — no compile error, the code just stops being called. Never give an extension member a name the class already uses.
- `notifyListeners()` is `@protected`, so calling it from an extension trips `invalid_use_of_visible_for_testing_member` (warning, non-fatal). It is currently accepted in `store_ocstore_cache.dart:22`; prefer moving a member back into the class body over adding more of these.

## Deliberately still large — do not re-attempt
`lib/l10n/strings.dart` (1154, one `class S` of static strings) and `lib/ui/line_icons/line_icons_painter.dart` (934, one `CustomPainter` of drawing paths) cannot be split by a pure line move. Splitting them needs a logic change, so they stay as-is. `home/home_shell.dart` (651), `settings_page/settings_page_body.dart` (491) and `files_page/files_page_browser.dart` (459) are one-widget files; accepted as-is.

## Verifying changes
There is no local Flutter SDK and installing one is not allowed.
- `dart analyze` is unusable here (no package resolution -> thousands of missing-package errors). Do not read its output as a verdict.
- `dart format -o none <files>` is the only useful local check; it is a **parse** check. Ignore the `Package resolution error` warnings.
- The real gate is CI: every push to `main` runs `flutter analyze --no-fatal-infos --no-fatal-warnings` plus an APK build. Push and read the run: `gh run list --limit 1`, then `gh run view <id> --log-failed | grep "error •"`.
- After editing code, refresh the map with `python graphify/graphify_lite.py`.
