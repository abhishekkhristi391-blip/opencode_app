# GRAPHIFY - ONE COMMAND

Run this single command (from anywhere inside the project). Nothing else is needed:

    python graphify/graphify_lite.py

It refreshes the map only if code changed, then prints the full report. Everything you need is already in files. READ them, do not grep the project blindly:
- `graphify/GRAPH_REPORT.md`  god nodes (riskiest to edit), modules, folder dependencies, import cycles, orphan files, issues
- `graphify/FILES.md`         one card per file: what it defines, imports, who imports it, calls into, "if changed affects ...", issues, TODOs
- `graphify/graph.md`         every link as `A --relation--> B [EXTRACTED|INFERRED conf] file:line` (search it for a name)
- `graphify/graph.html`       visual map for the human

## Rules
0. Speed: map -> exact line ranges (see `Defines ... L120-165` in FILES.md) -> answer. Never explore. Never `find` outside the project folder.
1. Run the command AFTER you edit code files (the map is already loaded at session start).
2. Read GRAPH_REPORT.md first, then the FILES.md cards of the files involved, then open only those source files (max 5 per question).
3. EXTRACTED = seen in code (trust). INFERRED = name match only (verify before trusting).
4. Always cite `file:line`. If it is not in the map, say "not found in map". Never guess.
5. Answer first (1-3 lines), then evidence bullets, then next step. Diffs only, no full-file dumps.

## Bug-hunting recipe
1. Find the entry point of the symptom (screen / route / button / job) in FILES.md.
2. Follow Imports / Calls into from card to card until the failing output (use graph.md for exact links).
3. Check the Issues lines of every file on that path (broken imports, empty catch, swallowed exceptions, hardcoded secrets).
4. Check "If changed affects" before proposing a fix (blast radius).
5. Report: root cause (file:line, confidence %), evidence chain, minimal diff, side effects, 2 other suspects, how to verify.

## Optional extras (only if you need them, not required)
`python graphify/graphify_lite.py query|explain|path|impact "name"`
