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
