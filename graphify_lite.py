#!/usr/bin/env python3
"""
graphify_lite.py - single-file code graph tool (stdlib only, phone friendly)

  python graphify_lite.py build  [folder]
  python graphify_lite.py query   "word"        # find nodes + 2-hop neighbours
  python graphify_lite.py path    "A" "B"       # shortest connection A -> B
  python graphify_lite.py explain "X"           # who calls X, what X calls
  python graphify_lite.py impact  "X"           # everything that depends on X
  python graphify_lite.py report                # print GRAPH_REPORT.md
  python graphify_lite.py html                  # (re)make graph.html (offline, touch friendly)

Output goes to <folder>/graphify-out/: graph.json, graph.md, GRAPH_REPORT.md, graph.html
Tags: EXTRACTED = read directly in code, INFERRED = matched by name (confidence).
"""
import ast, os, re, sys, json, collections

IGNORE_DIRS = {".git", "node_modules", "venv", ".venv", "__pycache__", "build", "dist",
               ".next", ".idea", ".gradle", "graphify-out", "Pods", "target", ".dart_tool"}
LANG = {".py": "py", ".js": "js", ".jsx": "js", ".ts": "js", ".tsx": "js", ".mjs": "js",
        ".java": "gen", ".kt": "gen", ".go": "gen", ".rs": "gen", ".php": "gen",
        ".rb": "gen", ".cs": "gen", ".c": "gen", ".cpp": "gen", ".dart": "dart",
        ".swift": "gen"}
MAX_BYTES = 600_000
RATIONALE = re.compile(r"(?:#|//|/\*|\*)\s*(NOTE|IMPORTANT|HACK|WHY|TODO|FIXME|BUG|XXX)\b:?\s*(.*)", re.I)
SECRET = re.compile(r"""(?i)(api[_-]?key|secret|password|token)\s*[:=]\s*['"][A-Za-z0-9_\-/+=]{8,}['"]""")
COMMON = {"get", "set", "run", "main", "init", "__init__", "print", "len", "str", "int", "list",
          "dict", "open", "close", "add", "map", "filter", "format", "then", "catch", "push",
          "pop", "join", "split", "log", "test", "setup", "update", "delete", "name", "value",
          "type", "data", "call", "apply", "bind", "from", "keys", "values", "items", "next"}


class G:
    def __init__(self):
        self.nodes = {}      # id -> dict(kind,file,line,name)
        self.edges = []      # (src,dst,rel,tag,conf,file,line)
        self.issues = []     # (severity,msg,file,line)
        self.notes = []      # (kind,text,file,line)

    def node(self, nid, kind, file, line, name):
        self.nodes.setdefault(nid, {"kind": kind, "file": file, "line": line, "name": name})

    def edge(self, s, d, rel, tag="EXTRACTED", conf=1.0, file="", line=0):
        if s != d:
            self.edges.append((s, d, rel, tag, conf, file, line))


def walk(root):
    out = []
    for dp, dn, fn in os.walk(root):
        dn[:] = [d for d in dn if d not in IGNORE_DIRS and not d.startswith(".")]
        for f in fn:
            ext = os.path.splitext(f)[1].lower()
            p = os.path.join(dp, f)
            if f == os.path.basename(__file__):
                continue
            if ext in LANG and os.path.getsize(p) <= MAX_BYTES:
                out.append(os.path.relpath(p, root).replace("\\", "/"))
    return sorted(out)


def read(root, rel):
    try:
        with open(os.path.join(root, rel), encoding="utf-8", errors="ignore") as fh:
            return fh.read()
    except OSError:
        return ""


def resolve_py(mod, level, cur, files):
    parts = mod.split(".") if mod else []
    if level:
        base = cur.split("/")[:-1]
        base = base[: len(base) - (level - 1)] if level > 1 else base
        parts = base + parts
    cand = "/".join(parts)
    for c in (cand + ".py", cand + "/__init__.py"):
        if c in files:
            return c
    # absolute import where project root differs: match by suffix
    if not level and parts:
        for f in files:
            if f.endswith("/" + cand + ".py") or f.endswith("/" + cand + "/__init__.py"):
                return f
    return None


def resolve_js(spec, cur, files):
    if not spec.startswith("."):
        return "EXT"
    base = os.path.normpath(os.path.join(os.path.dirname(cur), spec)).replace("\\", "/")
    for ext in ("", ".js", ".jsx", ".ts", ".tsx", ".mjs", "/index.js", "/index.ts", "/index.tsx", "/index.jsx"):
        if base + ext in files:
            return base + ext
    return None


def scan_common(g, rel, text):
    for i, line in enumerate(text.splitlines(), 1):
        m = RATIONALE.search(line)
        if m:
            g.notes.append((m.group(1).upper(), m.group(2).strip()[:90], rel, i))
        if SECRET.search(line):
            g.issues.append(("CRITICAL", "possible hardcoded secret", rel, i))


def parse_py(g, rel, text, files, symbols_by_file):
    try:
        tree = ast.parse(text)
    except SyntaxError as e:
        g.issues.append(("CRITICAL", f"syntax error: {e.msg}", rel, e.lineno or 0))
        return
    defs = {}

    def add_def(name, kind, line, owner=None):
        nid = f"{rel}::{owner + '.' if owner else ''}{name}"
        g.node(nid, kind, rel, line, f"{owner + '.' if owner else ''}{name}")
        g.edge(rel, nid, "defines", file=rel, line=line)
        defs[name] = nid
        symbols_by_file[rel].append((name, nid))
        return nid

    for n in tree.body:
        if isinstance(n, (ast.FunctionDef, ast.AsyncFunctionDef)):
            add_def(n.name, "function", n.lineno)
        elif isinstance(n, ast.ClassDef):
            cid = add_def(n.name, "class", n.lineno)
            for b in n.bases:
                if isinstance(b, ast.Name):
                    g.edge(cid, "?" + b.id, "inherits", file=rel, line=n.lineno)
            for m in n.body:
                if isinstance(m, (ast.FunctionDef, ast.AsyncFunctionDef)):
                    add_def(m.name, "method", m.lineno, n.name)

    imported = {}
    for n in ast.walk(tree):
        if isinstance(n, ast.Import):
            for a in n.names:
                t = resolve_py(a.name, 0, rel, files)
                if t:
                    g.edge(rel, t, "imports", file=rel, line=n.lineno)
        elif isinstance(n, ast.ImportFrom):
            t = resolve_py(n.module or "", n.level, rel, files)
            if t is None and n.level:
                g.issues.append(("WARNING", f"unresolved relative import '{'.' * n.level}{n.module or ''}'", rel, n.lineno))
            for a in n.names:
                sub = resolve_py((n.module + "." if n.module else "") + a.name, n.level, rel, files)
                if sub:
                    g.edge(rel, sub, "imports", file=rel, line=n.lineno)
                    imported[a.asname or a.name] = sub
                elif t:
                    imported[a.asname or a.name] = t
            if t and not any(resolve_py((n.module + "." if n.module else "") + a.name, n.level, rel, files) for a in n.names):
                g.edge(rel, t, "imports", file=rel, line=n.lineno)
        elif isinstance(n, ast.ExceptHandler):
            if n.type is None:
                g.issues.append(("WARNING", "bare 'except:' hides errors", rel, n.lineno))
            if len(n.body) == 1 and isinstance(n.body[0], ast.Pass):
                g.issues.append(("WARNING", "exception swallowed with 'pass'", rel, n.lineno))
        elif isinstance(n, (ast.FunctionDef, ast.AsyncFunctionDef)):
            for d in n.args.defaults:
                if isinstance(d, (ast.List, ast.Dict, ast.Set)):
                    g.issues.append(("WARNING", f"mutable default argument in {n.name}()", rel, n.lineno))
        elif isinstance(n, ast.Call) and isinstance(n.func, ast.Name) and n.func.id in ("eval", "exec"):
            g.issues.append(("CRITICAL", f"{n.func.id}() call", rel, n.lineno))

    # calls: owner function -> callee name
    for fn in ast.walk(tree):
        if isinstance(fn, (ast.FunctionDef, ast.AsyncFunctionDef)):
            caller = None
            for k, v in defs.items():
                if g.nodes[v]["line"] == fn.lineno:
                    caller = v
            caller = caller or rel
            for c in ast.walk(fn):
                if isinstance(c, ast.Call):
                    f = c.func
                    name = f.id if isinstance(f, ast.Name) else (f.attr if isinstance(f, ast.Attribute) else None)
                    if name:
                        g.edge(caller, "?" + name, "calls", file=rel, line=getattr(c, "lineno", 0))
    return imported


JS_IMPORT = re.compile(r"""(?:import\s+(?:[^'"]*?\s+from\s+)?|require\(\s*|import\(\s*|export\s+[^'"]*?\s+from\s+)['"]([^'"]+)['"]""")
JS_DEF = [
    (re.compile(r"^\s*(?:export\s+)?(?:default\s+)?(?:abstract\s+)?class\s+([A-Za-z_$][\w$]*)"), "class"),
    (re.compile(r"^\s*(?:export\s+)?(?:default\s+)?(?:async\s+)?function\s*\*?\s*([A-Za-z_$][\w$]*)"), "function"),
    (re.compile(r"^\s*(?:export\s+)?(?:const|let|var)\s+([A-Za-z_$][\w$]*)\s*=\s*(?:async\s*)?(?:\([^)]*\)|[A-Za-z_$][\w$]*)\s*=>"), "function"),
    (re.compile(r"^\s*(?:export\s+)?(?:const|let|var)\s+([A-Za-z_$][\w$]*)\s*=\s*(?:async\s+)?function"), "function"),
]
GEN_DEF = [
    (re.compile(r"^\s*(?:public|private|protected|internal|abstract|final|open|data|sealed|static)?\s*(?:class|interface|struct|enum|object|trait)\s+([A-Za-z_]\w*)"), "class"),
    (re.compile(r"^\s*(?:pub\s+)?(?:async\s+)?(?:fn|func|def|fun|function)\s+(?:\([^)]*\)\s*)?([A-Za-z_]\w*)"), "function"),
    (re.compile(r"^\s*(?:public|private|protected|static|final|override|suspend|async|\s)+[\w<>\[\],.?]+\s+([A-Za-z_]\w*)\s*\([^;]*\)\s*(?:throws [\w, .]+)?\{?\s*$"), "function"),
]


def parse_regex(g, rel, text, files, symbols_by_file, lang):
    defs = GEN_DEF if lang == "gen" else JS_DEF
    lines = text.splitlines()
    for i, line in enumerate(lines, 1):
        for rx, kind in defs:
            m = rx.match(line)
            if m and m.group(1) not in ("if", "for", "while", "switch", "catch", "return", "else"):
                nid = f"{rel}::{m.group(1)}"
                g.node(nid, kind, rel, i, m.group(1))
                g.edge(rel, nid, "defines", file=rel, line=i)
                symbols_by_file[rel].append((m.group(1), nid))
                break
        if lang == "js":
            for m in JS_IMPORT.finditer(line):
                t = resolve_js(m.group(1), rel, files)
                if t is None:
                    g.issues.append(("CRITICAL", f"broken import '{m.group(1)}' (file not found)", rel, i))
                elif t != "EXT":
                    g.edge(rel, t, "imports", file=rel, line=i)
        if "catch" in line and re.search(r"catch\s*(\([^)]*\))?\s*\{\s*\}", line):
            g.issues.append(("WARNING", "empty catch block", rel, i))
        if lang == "js" and re.search(r"\.then\(", line) and "catch" not in text:
            pass



DART_IMPORT = re.compile(r"""^\s*(?:import|export)\s+['"]([^'"]+)['"]""")
DART_CLASS = re.compile(r"^(?:abstract\s+|sealed\s+|base\s+|final\s+|interface\s+)*(?:class|mixin|enum|extension(?:\s+type)?)\s+([A-Za-z_]\w*)")
DART_FUNC = re.compile(r"^( {0,2})(?:static\s+|external\s+)*(?:[A-Za-z_][\w.]*(?:<[^()=]*>)?\??)\s+(?:get\s+|set\s+)?([A-Za-z_]\w*)\s*(?:<[^()]*>)?\(")
DART_SKIP = ("return", "if", "for", "while", "switch", "else", "await", "throw", "const", "new",
             "final", "var", "late", "case", "catch", "assert", "yield", "import", "export", "part", "typedef")


def resolve_dart(spec, cur, files, pkg):
    if spec.startswith("dart:"):
        return "EXT"
    if spec.startswith("package:"):
        rest = spec[8:]
        name, _, path = rest.partition("/")
        if pkg and name != pkg:
            return "EXT"
        for c in ("lib/" + path, path):
            if c in files:
                return c
        return "EXT" if not pkg else None
    base = os.path.normpath(os.path.join(os.path.dirname(cur), spec)).replace("\\", "/")
    return base if base in files else None


def parse_dart(g, rel, text, files, symbols_by_file, pkg):
    for i, line in enumerate(text.splitlines(), 1):
        st = line.strip()
        if not st or st.startswith(("//", "/*", "*")):
            continue
        m = DART_IMPORT.match(line)
        if m:
            t = resolve_dart(m.group(1), rel, files, pkg)
            if t is None:
                g.issues.append(("CRITICAL", f"broken import '{m.group(1)}' (file not found)", rel, i))
            elif t != "EXT":
                g.edge(rel, t, "imports", file=rel, line=i)
            continue
        m = DART_CLASS.match(line)
        if m:
            nid = f"{rel}::{m.group(1)}"
            g.node(nid, "class", rel, i, m.group(1))
            g.edge(rel, nid, "defines", file=rel, line=i)
            symbols_by_file[rel].append((m.group(1), nid))
            continue
        m = DART_FUNC.match(line)
        if m and m.group(2) not in DART_SKIP and st.split()[0] not in DART_SKIP:
            if st.endswith(("{", "=>", "(", ",", "async {", "async* {", "sync* {")) or "=>" in st or st.endswith(") {"):
                nid = f"{rel}::{m.group(2)}"
                if nid not in g.nodes:
                    g.node(nid, "function", rel, i, m.group(2))
                    g.edge(rel, nid, "defines", file=rel, line=i)
                    symbols_by_file[rel].append((m.group(2), nid))
        if re.search(r"catch\s*(\([^)]*\))?\s*\{\s*\}", line):
            g.issues.append(("WARNING", "empty catch block", rel, i))


def link_calls(g, files, symbols_by_file, texts, owners):
    by_name = collections.defaultdict(list)
    for f, syms in symbols_by_file.items():
        for name, nid in syms:
            by_name[name.split(".")[-1]].append(nid)
    new = []
    for s, d, rel, tag, conf, f, l in g.edges:
        if d.startswith("?"):
            name = d[1:]
            cands = [c for c in by_name.get(name, []) if c != s]
            if not cands or name in COMMON:
                continue
            same = [c for c in cands if g.nodes[c]["file"] == f]
            if same:
                new.append((s, same[0], rel, "EXTRACTED", 0.9, f, l))
            elif len(cands) == 1:
                new.append((s, cands[0], rel, "INFERRED", 0.7, f, l))
            elif len(cands) <= 3:
                for c in cands:
                    new.append((s, c, rel, "INFERRED", round(0.4 / 1, 2), f, l))
        else:
            new.append((s, d, rel, tag, conf, f, l))
    g.edges = dedupe(new)
    # regex languages: file-level name-reference calls (INFERRED)
    for f, text in texts.items():
        if LANG.get(os.path.splitext(f)[1]) in ("js", "gen", "dart"):
            for name, ids in by_name.items():
                if name in COMMON or len(name) < 4:
                    continue
                if re.search(r"\b" + re.escape(name) + r"\s*\(", text):
                    for c in ids:
                        if g.nodes[c]["file"] != f and len(ids) <= 3:
                            g.edge(f, c, "calls", "INFERRED", 0.6 if len(ids) == 1 else 0.35, f, 0)
    g.edges = dedupe(g.edges)


def dedupe(edges):
    seen, out = {}, []
    for e in edges:
        k = (e[0], e[1], e[2])
        if k not in seen or e[4] > seen[k][4]:
            seen[k] = e
    return list(seen.values())


def file_of(g, nid):
    return g.nodes[nid]["file"] if nid in g.nodes else nid


def analyze(g):
    deg = collections.Counter()
    for s, d, *_ in g.edges:
        deg[s] += 1
        deg[d] += 1
    # file graph
    fadj = collections.defaultdict(set)   # imports only -> cycles
    cadj = collections.defaultdict(set)   # imports + confident calls -> communities
    inb = collections.Counter()
    for s, d, rel, tag, conf, *_ in g.edges:
        fs, fd = file_of(g, s), file_of(g, d)
        if fs != fd and fs in g.nodes and fd in g.nodes:
            if rel == "imports":
                fadj[fs].add(fd); cadj[fs].add(fd); inb[fd] += 1
            elif rel in ("calls", "inherits") and conf >= 0.7:
                cadj[fs].add(fd); inb[fd] += 1
    # cycles (Tarjan)
    idx, low, onst, st, sccs, c = {}, {}, set(), [], [], [0]
    sys.setrecursionlimit(10000)

    def sc(v):
        idx[v] = low[v] = c[0]; c[0] += 1
        st.append(v); onst.add(v)
        for w in fadj.get(v, ()):
            if w not in idx:
                sc(w); low[v] = min(low[v], low[w])
            elif w in onst:
                low[v] = min(low[v], idx[w])
        if low[v] == idx[v]:
            comp = []
            while True:
                w = st.pop(); onst.discard(w); comp.append(w)
                if w == v:
                    break
            if len(comp) > 1:
                sccs.append(sorted(comp))

    for v in list(fadj):
        if v not in idx:
            sc(v)
    # communities: label propagation on undirected file graph
    und = collections.defaultdict(set)
    for a, bs in cadj.items():
        for b in bs:
            und[a].add(b); und[b].add(a)
    label = {f: f for f in und}
    for _ in range(12):
        changed = False
        for f in sorted(und):
            cnt = collections.Counter(label[n] for n in und[f])
            if cnt:
                best = sorted(cnt.items(), key=lambda x: (-x[1], x[0]))[0][0]
                if best != label[f]:
                    label[f] = best; changed = True
        if not changed:
            break
    comm = collections.defaultdict(list)
    for f, l in label.items():
        comm[l].append(f)
    communities = sorted([sorted(v) for v in comm.values() if len(v) > 1], key=lambda x: -len(x))
    files = [n for n, v in g.nodes.items() if v["kind"] == "file"]
    entry = re.compile(r"(main|index|app|server|manage|__init__|cli|test|setup|config|wsgi|asgi)", re.I)
    has_imp = {"py", "js", "dart"}
    orphans = [f for f in files if inb[f] == 0 and LANG.get(os.path.splitext(f)[1]) in has_imp
               and not entry.search(os.path.basename(f))]
    return deg, sccs, communities, orphans


def build(root):
    root = os.path.abspath(root)
    files_list = walk(root)
    files = set(files_list)
    g = G()
    symbols_by_file = collections.defaultdict(list)
    texts = {}
    pkg = ""
    pp = os.path.join(root, "pubspec.yaml")
    if os.path.exists(pp):
        m = re.search(r"^name:\s*([\w]+)", open(pp, errors="ignore").read(), re.M)
        pkg = m.group(1) if m else ""
    for rel in files_list:
        text = read(root, rel)
        texts[rel] = text
        lang = LANG[os.path.splitext(rel)[1].lower()]
        g.node(rel, "file", rel, 1, rel)
        scan_common(g, rel, text)
        if lang == "py":
            parse_py(g, rel, text, files, symbols_by_file)
        elif lang == "dart":
            parse_dart(g, rel, text, files, symbols_by_file, pkg)
        else:
            parse_regex(g, rel, text, files, symbols_by_file, lang)
    # resolve inheritance & calls
    link_calls(g, files, symbols_by_file, texts, None)
    g.edges = [e for e in g.edges if not e[1].startswith("?") and e[0] in g.nodes and e[1] in g.nodes]
    out = os.path.join(root, "graphify-out")
    os.makedirs(out, exist_ok=True)
    deg, sccs, communities, orphans = analyze(g)
    meta = make_meta(g, communities)
    with open(os.path.join(out, "graph.json"), "w") as fh:
        json.dump({"nodes": g.nodes, "edges": g.edges, "meta": meta}, fh)
    with open(os.path.join(out, "graph.md"), "w") as fh:
        for s, d, rel, tag, conf, f, l in sorted(g.edges):
            t = tag if tag == "EXTRACTED" else f"INFERRED {conf}"
            fh.write(f"{s} --{rel}--> {d} [{t}] {f}:{l}\n")
    rep = report(g, deg, sccs, communities, orphans, len(files_list))
    with open(os.path.join(out, "GRAPH_REPORT.md"), "w") as fh:
        fh.write(rep)
    hp = write_html(out, g.nodes, g.edges, meta, rep)
    print(rep)
    print(f"\nSaved: {out}/ (graph.json, graph.md, GRAPH_REPORT.md, graph.html)")
    print(f"Open graph: termux-open {hp}   (or: cd graphify-out && python -m http.server 8000 -> http://localhost:8000/graph.html)")


def report(g, deg, sccs, communities, orphans, nfiles):
    L = []
    nsym = sum(1 for v in g.nodes.values() if v["kind"] != "file")
    ex = sum(1 for e in g.edges if e[3] == "EXTRACTED")
    L.append("# GRAPH REPORT")
    L.append(f"{nfiles} files, {nsym} symbols, {len(g.edges)} edges ({ex} EXTRACTED, {len(g.edges) - ex} INFERRED)\n")
    L.append("## God nodes (most connected = riskiest to edit)")
    gods = [(n, d) for n, d in deg.most_common(40) if g.nodes.get(n, {}).get("kind") != "file"][:10]
    for n, d in gods:
        v = g.nodes[n]
        L.append(f"- {v['name']} ({v['kind']}) - {d} links - {v['file']}:{v['line']}")
    L.append("\n## Communities (modules that talk to each other)")
    for i, c in enumerate(communities[:8], 1):
        L.append(f"{i}. {len(c)} files: " + ", ".join(c[:5]) + (" ..." if len(c) > 5 else ""))
    fd = collections.Counter()
    for s_, d_, rel, *_ in g.edges:
        if rel == "imports":
            a, b = os.path.dirname(file_of(g, s_)) or ".", os.path.dirname(file_of(g, d_)) or "."
            if a != b:
                fd[(a, b)] += 1
    L.append("\n## Folder dependencies (who imports whom)")
    for (a, b), n in fd.most_common(10):
        L.append(f"- {a} -> {b}  ({n} imports)")
    if not fd:
        L.append("- none")
    L.append("\n## Circular imports (real import cycles only)")
    L += [f"- {' <-> '.join(c[:5])}" for c in sccs[:8]] or ["- none found"]
    L.append("\n## Orphan files (nobody imports them: dead code?)")
    L += [f"- {o}" for o in orphans[:15]] or ["- none"]
    L.append("\n## Issues / suspicious spots")
    order = {"CRITICAL": 0, "WARNING": 1}
    for sev, msg, f, l in sorted(g.issues, key=lambda x: order.get(x[0], 2))[:40]:
        L.append(f"- [{sev}] {msg} - {f}:{l}")
    if not g.issues:
        L.append("- none")
    L.append("\n## Rationale / TODO notes")
    for k, t, f, l in g.notes[:25]:
        L.append(f"- {k}: {t} - {f}:{l}")
    L.append("\n## Suggested questions")
    if gods:
        L.append(f"- What breaks if I change {gods[0][0].split('::')[-1]}?   -> impact")
        L.append(f"- How does {gods[0][0].split('::')[-1]} connect to <your module>?   -> path")
    L.append("- Which files depend on the most-connected file?   -> explain")
    L.append("\nNOTE: INFERRED edges are name-matches. Verify before trusting.")
    return "\n".join(L) + "\n"


HTML_TPL = r'''<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title>graphify-lite graph</title>
<style>
*{box-sizing:border-box;margin:0;padding:0;-webkit-tap-highlight-color:transparent}
html,body{height:100%;background:#0f0f1a;color:#e0e0e0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;overflow:hidden}
#cv{position:fixed;left:0;top:0;width:100%;height:100%;touch-action:none;display:block}
#top{position:fixed;left:0;right:0;top:0;padding:calc(8px + env(safe-area-inset-top)) 8px 8px;display:flex;gap:6px;z-index:5;background:linear-gradient(#0f0f1a,#0f0f1acc 70%,transparent)}
#q{flex:1;min-width:0;background:#1a1a2e;border:1px solid #3a3a5e;color:#e0e0e0;padding:10px 12px;border-radius:10px;font-size:15px;outline:none}
#q:focus{border-color:#4E79A7}
.btn{background:#1a1a2e;border:1px solid #3a3a5e;color:#e0e0e0;border-radius:10px;width:42px;font-size:18px;cursor:pointer}
#res{position:fixed;left:8px;right:8px;top:calc(56px + env(safe-area-inset-top));max-height:40vh;overflow:auto;background:#1a1a2e;border:1px solid #2a2a4e;border-radius:10px;display:none;z-index:6}
.si{padding:9px 12px;font-size:13px;border-bottom:1px solid #23233d;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;cursor:pointer}
.si small{color:#777;margin-left:6px}
#badge{position:fixed;left:10px;top:calc(62px + env(safe-area-inset-top));font-size:11px;color:#6a6a8a;z-index:3;pointer-events:none}
#sheet{position:fixed;left:0;right:0;bottom:0;max-height:46vh;overflow:auto;background:#1a1a2ef5;border-top:1px solid #2a2a4e;border-radius:14px 14px 0 0;padding:12px 14px calc(14px + env(safe-area-inset-bottom));z-index:4;display:none;font-size:13px;line-height:1.5}
@media(min-width:900px){#sheet{left:auto;top:0;right:0;width:350px;max-height:none;border-radius:0;border-top:0;border-left:1px solid #2a2a4e;padding-top:70px}}
.hd{display:flex;justify-content:space-between;gap:10px;align-items:flex-start;font-size:15px;margin-bottom:4px;word-break:break-all}
.x{cursor:pointer;color:#999;padding:0 4px;font-size:18px}
.f{color:#aaa;font-size:12px;word-break:break-all}
.cr{color:#ff7b72}.wr{color:#e3b341}
.iss{margin-top:8px;color:#e3b341;font-size:12px}
.sec{margin-top:10px;margin-bottom:3px;color:#8a8aaa;font-size:11px;text-transform:uppercase;letter-spacing:.05em}
.nb{display:flex;align-items:center;gap:7px;padding:6px 4px;border-radius:5px;cursor:pointer;font-size:12px;border-bottom:1px solid #23233d}
.nb:active,.si:active{background:#2a2a4e}
.dot{width:10px;height:10px;border-radius:50%;flex-shrink:0;display:inline-block}
.tg{margin-left:auto;color:#7b8bb8;font-size:11px;flex-shrink:0;padding-left:6px}
.tg.inf{color:#e3b341}
#drawer{position:fixed;top:0;bottom:0;right:0;width:min(88vw,330px);background:#1a1a2e;border-left:1px solid #2a2a4e;z-index:8;transform:translateX(105%);transition:transform .2s;overflow:auto;padding:calc(12px + env(safe-area-inset-top)) 14px 24px;font-size:13px}
#drawer.open{transform:none}
.seg{display:flex;gap:6px;margin:6px 0}
.seg button,.mini{flex:1;background:#0f0f1a;border:1px solid #3a3a5e;color:#ccc;padding:8px;border-radius:8px;font-size:12px}
.seg button.on{background:#4E79A7;border-color:#4E79A7;color:#fff}
.mini{flex:none;padding:5px 12px;margin-right:6px}
label.row{display:flex;align-items:center;gap:8px;padding:7px 0;color:#ccc;cursor:pointer}
.gi{display:flex;align-items:center;gap:8px;padding:6px 0;cursor:pointer;font-size:12px}
.gi span.nm{flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.cnt{color:#666;font-size:11px}
.leg{margin-top:12px;color:#777;font-size:11px;line-height:1.7}
#rep{position:fixed;left:0;top:0;right:0;bottom:0;background:#0f0f1af7;z-index:9;display:none;overflow:auto;padding:calc(14px + env(safe-area-inset-top)) 14px 30px}
#rep pre{white-space:pre-wrap;font:12px/1.55 ui-monospace,Menlo,Consolas,monospace;color:#cfcfe0;margin-top:12px}
</style></head><body>
<canvas id="cv"></canvas>
<div id="top"><input id="q" placeholder="Search nodes / files..." autocomplete="off"><button class="btn" id="bFit" title="Fit">&#x2922;</button><button class="btn" id="bRep" title="Report">&#x1F4CB;</button><button class="btn" id="bMenu" title="Filters">&#x2630;</button></div>
<div id="res"></div>
<div id="badge"></div>
<div id="sheet"></div>
<div id="drawer"></div>
<div id="rep"><button class="btn" id="bRepClose" style="width:auto;padding:8px 14px;font-size:14px">&#x2715; Close</button><pre id="repText"></pre></div>
<script id="data" type="application/json">__DATA__</script>
<script>
(function(){
var D=JSON.parse(document.getElementById('data').textContent);
var PAL=["#4E79A7","#F28E2B","#E15759","#76B7B2","#59A14F","#EDC948","#B07AA1","#FF9DA7","#9C755F","#BAB0AC"];
function $(id){return document.getElementById(id);}
function esc(s){return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');}
var N=D.nodes.map(function(a,i){return {i:i,name:a[0],kind:a[1],file:a[2],line:a[3],dir:a[4],comm:a[5],deg:a[6]};});
var E=D.edges.map(function(a){return {s:a[0],t:a[1],rel:a[2],tag:a[3],conf:a[4]};});
var fileIdx={};N.forEach(function(n){if(n.kind==='file')fileIdx[n.file]=n.i;});
var issuesBy={};(D.issues||[]).forEach(function(x){(issuesBy[x[2]]=issuesBy[x[2]]||[]).push(x);});
var colorBy='dir',showSym=N.length<=700,showInf=true,hidden={},sel=-1,nbset={};
var vn=[],ve=[],adj={},groups=[],gcol={},labelMin=2,alpha=1,ticks=0,dirty=true,userMoved=false;
var cv=$('cv'),ctx=cv.getContext('2d'),W=0,H=0,dpr=window.devicePixelRatio||1,tx=0,ty=0,k=1;
function label(n){return n.kind==='file'?n.file.split('/').pop():n.name;}
function gkey(n){return colorBy==='dir'?n.dir:String(n.comm);}
function gname(key){return colorBy==='dir'?key:((D.comm_names&&D.comm_names[+key])||'isolated');}
function computeGroups(){
  var cnt={};N.forEach(function(n){var q=gkey(n);cnt[q]=(cnt[q]||0)+1;});
  groups=Object.keys(cnt).sort(function(a,b){return cnt[b]-cnt[a];}).map(function(q,i){return {k:q,name:gname(q),n:cnt[q],color:PAL[i%PAL.length]};});
  gcol={};groups.forEach(function(g){gcol[g.k]=g.color;});
}
function visibleNode(n){return (n.kind==='file'||showSym)&&!hidden[gkey(n)];}
/*PHYS_START*/
function physics(vn,ve,alpha){
  var CELL=110,grid={},i,j,n,m,e;
  for(i=0;i<vn.length;i++){n=vn[i];n._cx=Math.floor(n.x/CELL);n._cy=Math.floor(n.y/CELL);var key=n._cx+','+n._cy;(grid[key]=grid[key]||[]).push(n);}
  for(i=0;i<vn.length;i++){
    n=vn[i];
    for(var ox=-1;ox<=1;ox++)for(var oy=-1;oy<=1;oy++){
      var c=grid[(n._cx+ox)+','+(n._cy+oy)];if(!c)continue;
      for(j=0;j<c.length;j++){m=c[j];if(m===n)continue;
        var dx=n.x-m.x,dy=n.y-m.y,d2=dx*dx+dy*dy;
        if(d2<1){dx=Math.random()-0.5;dy=Math.random()-0.5;d2=dx*dx+dy*dy+1;}
        var d=Math.sqrt(d2),f=(150/d)*alpha;
        n.vx+=dx/d*f;n.vy+=dy/d*f;
      }
    }
  }
  for(i=0;i<ve.length;i++){
    e=ve[i];var a=e.a,b=e.b,ex=b.x-a.x,ey=b.y-a.y,ed=Math.sqrt(ex*ex+ey*ey)||1;
    var def=e.rel==='defines',L=def?34:85,ff=(ed-L)*(def?0.09:0.04)*alpha,fx=ex/ed*ff,fy=ey/ed*ff;
    a.vx+=fx;a.vy+=fy;b.vx-=fx;b.vy-=fy;
  }
  for(i=0;i<vn.length;i++){
    n=vn[i];if(n.fixed){n.vx=0;n.vy=0;continue;}
    n.vx-=n.x*0.004*alpha;n.vy-=n.y*0.004*alpha;
    n.vx*=0.78;n.vy*=0.78;
    if(n.vx>40)n.vx=40;if(n.vx<-40)n.vx=-40;if(n.vy>40)n.vy=40;if(n.vy<-40)n.vy=-40;
    n.x+=n.vx;n.y+=n.vy;
  }
}
/*PHYS_END*/
function rebuild(){
  var vis={};vn=[];
  N.forEach(function(n){if(visibleNode(n)){vis[n.i]=true;vn.push(n);}});
  var seen={};ve=[];
  E.forEach(function(e){
    if(e.tag==='INFERRED'&&!showInf)return;
    var a=e.s,b=e.t;
    if(!showSym){if(e.rel==='defines')return;a=fileIdx[N[a].file];b=fileIdx[N[b].file];if(a===undefined||b===undefined)return;}
    if(a===b||!vis[a]||!vis[b])return;
    var key=a+'>'+b+'>'+e.rel;if(seen[key])return;seen[key]=1;
    ve.push({a:N[a],b:N[b],rel:e.rel,tag:e.tag,conf:e.conf});
  });
  adj={};ve.forEach(function(e){(adj[e.a.i]=adj[e.a.i]||[]).push(e);(adj[e.b.i]=adj[e.b.i]||[]).push(e);});
  vn.forEach(function(n,j){n.vd=0;if(n.x===undefined){var r=30*Math.sqrt(j);n.x=r*Math.cos(j*2.4);n.y=r*Math.sin(j*2.4);n.vx=0;n.vy=0;}});
  ve.forEach(function(e){e.a.vd++;e.b.vd++;});
  var ds=vn.map(function(n){return n.vd;}).sort(function(x,y){return y-x;});
  labelMin=ds.length?Math.max(2,ds[Math.floor(ds.length*0.12)]||2):2;
  alpha=1;ticks=0;if(sel>=0&&!vis[sel])sel=-1;
  computeNb();renderSheet();dirty=true;$('badge').textContent=vn.length+' nodes · '+ve.length+' edges shown ('+N.length+' / '+E.length+' total)';
}
function computeNb(){nbset={};if(sel<0)return;(adj[sel]||[]).forEach(function(e){nbset[e.a.i]=1;nbset[e.b.i]=1;});}
function rad(n){return (n.kind==='file'?5:3.2)+Math.sqrt(n.vd||0)*1.8;}
function resize(){W=window.innerWidth;H=window.innerHeight;dpr=window.devicePixelRatio||1;cv.width=Math.round(W*dpr);cv.height=Math.round(H*dpr);if(tx===0&&ty===0){tx=W/2;ty=H/2;}dirty=true;}
function fit(){
  if(!vn.length)return;var x0=1e9,y0=1e9,x1=-1e9,y1=-1e9;
  vn.forEach(function(n){if(n.x<x0)x0=n.x;if(n.x>x1)x1=n.x;if(n.y<y0)y0=n.y;if(n.y>y1)y1=n.y;});
  var pad=40,bw=Math.max(x1-x0,50),bh=Math.max(y1-y0,50),aw=W-(W>=900?350:0);
  k=Math.max(0.05,Math.min(3,Math.min((aw-pad*2)/bw,(H-pad*2-60)/bh)));
  tx=aw/2-((x0+x1)/2)*k;ty=H/2+20-((y0+y1)/2)*k;dirty=true;
}
function draw(){
  ctx.setTransform(dpr,0,0,dpr,0,0);ctx.globalAlpha=1;ctx.fillStyle='#0f0f1a';ctx.fillRect(0,0,W,H);
  ctx.save();ctx.translate(tx,ty);ctx.scale(k,k);ctx.lineCap='round';
  var i,e,n,hasSel=sel>=0;
  for(i=0;i<ve.length;i++){
    e=ve[i];var hot=hasSel&&(e.a.i===sel||e.b.i===sel),def=e.rel==='defines';
    ctx.globalAlpha=hasSel?(hot?0.95:0.05):(def?0.2:(e.tag==='INFERRED'?0.32:0.45));
    ctx.strokeStyle=hot?'#ffffff':(def?'#6b6b8a':'#9aa0c8');ctx.lineWidth=(hot?2:1)/k;
    ctx.setLineDash(e.tag==='INFERRED'?[5/k,4/k]:[]);
    ctx.beginPath();ctx.moveTo(e.a.x,e.a.y);ctx.lineTo(e.b.x,e.b.y);ctx.stroke();
    if(hot&&!def){var dx=e.b.x-e.a.x,dy=e.b.y-e.a.y,dl=Math.sqrt(dx*dx+dy*dy)||1,ux=dx/dl,uy=dy/dl,r=rad(e.b)+2/k,px=e.b.x-ux*r,py=e.b.y-uy*r,s=7/k;
      ctx.setLineDash([]);ctx.fillStyle='#fff';ctx.beginPath();ctx.moveTo(px,py);ctx.lineTo(px-ux*s-uy*s*0.5,py-uy*s+ux*s*0.5);ctx.lineTo(px-ux*s+uy*s*0.5,py-uy*s-ux*s*0.5);ctx.closePath();ctx.fill();}
  }
  ctx.setLineDash([]);
  for(i=0;i<vn.length;i++){
    n=vn[i];var r2=rad(n),dim=hasSel&&n.i!==sel&&!nbset[n.i];
    ctx.globalAlpha=dim?0.15:1;ctx.fillStyle=gcol[gkey(n)]||'#888';
    if(n.kind==='file'){ctx.fillRect(n.x-r2,n.y-r2,2*r2,2*r2);}else{ctx.beginPath();ctx.arc(n.x,n.y,r2,0,6.2832);ctx.fill();}
    if(n.i===sel){ctx.globalAlpha=1;ctx.strokeStyle='#fff';ctx.lineWidth=2.5/k;if(n.kind==='file')ctx.strokeRect(n.x-r2,n.y-r2,2*r2,2*r2);else{ctx.beginPath();ctx.arc(n.x,n.y,r2,0,6.2832);ctx.stroke();}}
  }
  ctx.textAlign='center';ctx.font=(11/k)+'px sans-serif';ctx.lineJoin='round';
  for(i=0;i<vn.length;i++){
    n=vn[i];var show=hasSel?(n.i===sel||nbset[n.i]):(n.vd>=labelMin||k>1.6);
    if(!show)continue;
    var tl=label(n),ty2=n.y+rad(n)+11/k;
    ctx.globalAlpha=0.95;ctx.strokeStyle='#0f0f1a';ctx.lineWidth=3/k;ctx.strokeText(tl,n.x,ty2);ctx.fillStyle='#fff';ctx.fillText(tl,n.x,ty2);
  }
  ctx.restore();
}
function loop(){
  if(alpha>0.03){physics(vn,ve,alpha);alpha*=0.985;ticks++;dirty=true;if(!userMoved&&(ticks===60||ticks===130||ticks===220))fit();}
  if(dirty){draw();dirty=false;}
  requestAnimationFrame(loop);
}
function toWorld(x,y){return {x:(x-tx)/k,y:(y-ty)/k};}
function hit(x,y){var w=toWorld(x,y),best=null,bd=1e9;
  for(var i=vn.length-1;i>=0;i--){var n=vn[i],dx=n.x-w.x,dy=n.y-w.y,d=Math.sqrt(dx*dx+dy*dy);if(d<=rad(n)+14/k&&d<bd){bd=d;best=n;}}
  return best;}
function zoomAt(mx,my,f){var nk=Math.max(0.05,Math.min(8,k*f));f=nk/k;tx=mx-(mx-tx)*f;ty=my-(my-ty)*f;k=nk;dirty=true;}
function select(i){sel=i;computeNb();renderSheet();dirty=true;}
function focusNode(i){
  var n=N[i];
  if(!visibleNode(n)){if(n.kind!=='file'&&!showSym){showSym=true;}delete hidden[gkey(n)];renderDrawer();rebuild();}
  select(i);k=Math.max(k,1.3);var narrow=W<900;
  tx=(narrow?W/2:(W-350)/2)-n.x*k;ty=(narrow?H*0.28:H/2)-n.y*k;userMoved=true;dirty=true;
}
var ptrs={},np=0,drag=null,moved=0,downT=0,pinch=null;
cv.addEventListener('pointerdown',function(e){
  try{cv.setPointerCapture(e.pointerId);}catch(x){}
  if(!ptrs[e.pointerId])np++;ptrs[e.pointerId]={x:e.clientX,y:e.clientY};
  if(np===1){moved=0;downT=Date.now();drag=hit(e.clientX,e.clientY);if(drag)drag.fixed=true;}
  else if(np===2){if(drag){drag.fixed=false;drag=null;}var p=Object.keys(ptrs).map(function(q){return ptrs[q];});pinch={d:Math.hypot(p[0].x-p[1].x,p[0].y-p[1].y)||1};moved=99;}
});
cv.addEventListener('pointermove',function(e){
  var p=ptrs[e.pointerId];if(!p)return;var dx=e.clientX-p.x,dy=e.clientY-p.y;p.x=e.clientX;p.y=e.clientY;
  if(np>=2&&pinch){var q=Object.keys(ptrs).map(function(z){return ptrs[z];}),d=Math.hypot(q[0].x-q[1].x,q[0].y-q[1].y)||1;
    zoomAt((q[0].x+q[1].x)/2,(q[0].y+q[1].y)/2,d/pinch.d);pinch.d=d;userMoved=true;return;}
  moved+=Math.abs(dx)+Math.abs(dy);
  if(drag){if(moved>6){var w=toWorld(e.clientX,e.clientY);drag.x=w.x;drag.y=w.y;drag.vx=0;drag.vy=0;if(alpha<0.3)alpha=0.3;dirty=true;}}
  else{tx+=dx;ty+=dy;userMoved=true;dirty=true;}
});
function up(e){
  if(!ptrs[e.pointerId])return;delete ptrs[e.pointerId];np--;
  if(np<=0){np=0;if(drag)drag.fixed=false;
    if(moved<8&&Date.now()-downT<600){var h=hit(e.clientX,e.clientY);select(h?h.i:-1);}
    drag=null;pinch=null;}
  else if(np===1){pinch=null;moved=99;}
}
cv.addEventListener('pointerup',up);cv.addEventListener('pointercancel',up);
cv.addEventListener('wheel',function(e){e.preventDefault();zoomAt(e.clientX,e.clientY,Math.exp(-e.deltaY*0.0015));userMoved=true;},{passive:false});
function renderSheet(){
  var s=$('sheet');if(sel<0){s.style.display='none';return;}
  var n=N[sel],out=[],inn=[];s.style.display='block';
  (adj[sel]||[]).forEach(function(e){if(e.a.i===sel)out.push(e);else inn.push(e);});
  function row(e,o){return '<div class="nb" data-i="'+o.i+'"><span class="dot" style="background:'+(gcol[gkey(o)]||'#888')+'"></span><span>'+esc(o.kind==='file'?o.file:o.name)+'</span><span class="tg'+(e.tag==='INFERRED'?' inf':'')+'">'+esc(e.rel)+(e.tag==='INFERRED'?' ~'+e.conf:'')+'</span></div>';}
  var h='<div class="hd"><b>'+esc(n.kind==='file'?n.file:n.name)+'</b><span class="x" id="sx">&#x2715;</span></div>';
  h+='<div class="f">'+esc(n.kind)+' &middot; '+esc(n.file)+':'+n.line+'</div>';
  h+='<div class="f">Folder: '+esc(n.dir)+' &middot; Community: '+esc(gname(String(n.comm)).replace(/^$/,'-'))+' &middot; Links: '+n.deg+'</div>';
  var is=issuesBy[n.file]||[];
  if(is.length){h+='<div class="iss">&#9888; Issues in this file</div>';is.slice(0,6).forEach(function(x){h+='<div class="f '+(x[0]==='CRITICAL'?'cr':'wr')+'">['+esc(x[0])+'] '+esc(x[1])+' :'+x[3]+'</div>';});}
  if(out.length){h+='<div class="sec">Uses &rarr; ('+out.length+')</div>';out.slice(0,40).forEach(function(e){h+=row(e,e.b);});}
  if(inn.length){h+='<div class="sec">Used by &larr; ('+inn.length+')</div>';inn.slice(0,40).forEach(function(e){h+=row(e,e.a);});}
  s.innerHTML=h;s.scrollTop=0;
}
$('sheet').addEventListener('click',function(e){
  var t=e.target;if(t.id==='sx'){select(-1);return;}
  while(t&&t!==this&&!(t.dataset&&t.dataset.i!==undefined))t=t.parentNode;
  if(t&&t.dataset&&t.dataset.i!==undefined)focusNode(+t.dataset.i);
});
$('q').addEventListener('input',function(){
  var q=this.value.trim().toLowerCase(),r=$('res');
  if(!q){r.style.display='none';return;}
  var m=N.filter(function(n){return n.name.toLowerCase().indexOf(q)>=0||n.file.toLowerCase().indexOf(q)>=0;}).sort(function(a,b){return b.deg-a.deg;}).slice(0,25);
  if(!m.length){r.style.display='none';return;}
  r.style.display='block';
  r.innerHTML=m.map(function(n){return '<div class="si" data-i="'+n.i+'"><span class="dot" style="background:'+(gcol[gkey(n)]||'#888')+'"></span> '+esc(n.kind==='file'?n.file:n.name)+'<small>'+esc(n.kind==='file'?'file':n.file+':'+n.line)+'</small></div>';}).join('');
});
$('res').addEventListener('click',function(e){
  var t=e.target;while(t&&t!==this&&!(t.dataset&&t.dataset.i!==undefined))t=t.parentNode;
  if(t&&t.dataset&&t.dataset.i!==undefined){focusNode(+t.dataset.i);this.style.display='none';$('q').value='';$('q').blur();}
});
function renderDrawer(){
  var d=$('drawer'),h='<div class="hd"><b>Filters</b><span class="x" id="dx">&#x2715;</span></div>';
  h+='<div class="sec">Color by</div><div class="seg"><button data-cb="dir" class="'+(colorBy==='dir'?'on':'')+'">Folder</button><button data-cb="comm" class="'+(colorBy==='comm'?'on':'')+'">Community</button></div>';
  h+='<label class="row"><input type="checkbox" id="cSym" '+(showSym?'checked':'')+'> Show symbols (functions / classes)</label>';
  h+='<label class="row"><input type="checkbox" id="cInf" '+(showInf?'checked':'')+'> Show INFERRED edges (dashed)</label>';
  h+='<div class="sec">Groups</div><div style="margin-bottom:6px"><button class="mini" data-all="1">All</button><button class="mini" data-all="0">None</button></div>';
  groups.forEach(function(g,i){h+='<label class="gi"><input type="checkbox" data-g="'+i+'" '+(hidden[g.k]?'':'checked')+'><span class="dot" style="background:'+g.color+'"></span><span class="nm">'+esc(g.name)+'</span><span class="cnt">'+g.n+'</span></label>';});
  h+='<div class="leg">&#9632; file &nbsp; &#9679; symbol<br>solid line = EXTRACTED (seen in code)<br>dashed line = INFERRED (name match, verify!)<br>Tap node = inspect &middot; drag node = move<br>Pinch / wheel = zoom</div>';
  d.innerHTML=h;
}
$('drawer').addEventListener('click',function(e){
  var t=e.target;
  if(t.id==='dx'){this.classList.remove('open');return;}
  if(t.dataset&&t.dataset.cb){colorBy=t.dataset.cb;hidden={};computeGroups();renderDrawer();rebuild();return;}
  if(t.dataset&&t.dataset.all!==undefined){hidden={};if(t.dataset.all==='0')groups.forEach(function(g){hidden[g.k]=1;});renderDrawer();rebuild();}
});
$('drawer').addEventListener('change',function(e){
  var t=e.target;
  if(t.id==='cSym'){showSym=t.checked;rebuild();return;}
  if(t.id==='cInf'){showInf=t.checked;rebuild();return;}
  if(t.dataset&&t.dataset.g!==undefined){var g=groups[+t.dataset.g];if(t.checked)delete hidden[g.k];else hidden[g.k]=1;rebuild();}
});
$('bMenu').addEventListener('click',function(){$('drawer').classList.toggle('open');});
$('bFit').addEventListener('click',function(){userMoved=false;fit();});
$('bRep').addEventListener('click',function(){$('repText').textContent=D.report||'(no report)';$('rep').style.display='block';});
$('bRepClose').addEventListener('click',function(){$('rep').style.display='none';});
window.addEventListener('resize',resize);
computeGroups();renderDrawer();resize();rebuild();loop();
})();
</script>
</body></html>
'''


def write_html(out, nodes, edges, meta, rep):
    ids = list(nodes.keys())
    idx = {n: i for i, n in enumerate(ids)}
    deg = collections.Counter()
    for e in edges:
        deg[e[0]] += 1
        deg[e[1]] += 1
    cmap = meta.get("comm_of_file", {}) if meta else {}
    nl = []
    for n in ids:
        v = nodes[n]
        nl.append([v["name"], v["kind"], v["file"], v["line"],
                   os.path.dirname(v["file"]) or ".", cmap.get(v["file"], -1), deg[n]])
    el = [[idx[e[0]], idx[e[1]], e[2], e[3], e[4], e[5], e[6]] for e in edges if e[0] in idx and e[1] in idx]
    data = {"nodes": nl, "edges": el, "comm_names": (meta or {}).get("comm_names", []),
            "issues": (meta or {}).get("issues", []), "report": rep}
    blob = json.dumps(data).replace("<", "\\u003c")
    path = os.path.join(out, "graph.html")
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(HTML_TPL.replace("__DATA__", blob))
    return path


def make_meta(g, communities):
    cmap, names = {}, []
    for i, c in enumerate(communities):
        top = collections.Counter(os.path.dirname(f) or "." for f in c).most_common(1)[0][0]
        names.append(f"{top} ({len(c)} files) #{i + 1}")
        for f in c:
            cmap[f] = i
    return {"comm_of_file": cmap, "comm_names": names, "issues": g.issues}


def load(root):
    p = os.path.join(root, "graphify-out", "graph.json")
    if not os.path.exists(p):
        sys.exit("No graph yet. Run: python graphify_lite.py build .")
    with open(p) as fh:
        d = json.load(fh)
    return d["nodes"], [tuple(e) for e in d["edges"]]


def find(nodes, q):
    q = q.lower()
    if len(q) < 3:
        return [n for n, v in nodes.items() if v["name"].lower() == q][:4]
    exact = [n for n, v in nodes.items() if v["name"].lower() == q or v["name"].lower().split(".")[-1] == q or n.lower() == q]
    if exact:
        return sorted(exact, key=lambda n: nodes[n]["kind"] == "file")[:8]
    hits = [n for n, v in nodes.items() if q in v["name"].lower() or q in n.lower()]
    return sorted(hits, key=lambda n: nodes[n]["kind"] == "file")[:8]


def fmt(nodes, nid):
    v = nodes[nid]
    return f"{v['name']} ({v['kind']}) {v['file']}:{v['line']}"


def cmd_query(root, q):
    nodes, edges = load(root)
    hits = find(nodes, q)
    if not hits:
        return print("not found in graph")
    out_adj, in_adj = collections.defaultdict(list), collections.defaultdict(list)
    for s, d, rel, tag, conf, f, l in edges:
        out_adj[s].append((d, rel, tag, conf, f, l)); in_adj[d].append((s, rel, tag, conf, f, l))
    for h in hits[:3]:
        print(f"\n== {fmt(nodes, h)}")
        for d, rel, tag, conf, f, l in out_adj[h][:12]:
            print(f"  -{rel}-> {nodes[d]['name']}  [{tag[:3]} {conf}] {f}:{l}")
        for s, rel, tag, conf, f, l in in_adj[h][:12]:
            print(f"  <-{rel}- {nodes[s]['name']}  [{tag[:3]} {conf}] {f}:{l}")


def bfs_path(nodes, edges, a, b):
    adj = collections.defaultdict(list)
    for s, d, rel, tag, conf, f, l in edges:
        adj[s].append((d, rel, "->", tag, conf, f, l)); adj[d].append((s, rel, "<-", tag, conf, f, l))
    prev, dq = {a: None}, collections.deque([a])
    while dq:
        x = dq.popleft()
        if x == b:
            break
        for y, rel, dr, tag, conf, f, l in adj[x]:
            if y not in prev:
                prev[y] = (x, rel, dr, tag, conf, f, l); dq.append(y)
    if b not in prev:
        return None
    path, x = [], b
    while prev[x]:
        p = prev[x]; path.append((p[0], x, p[1], p[2], p[3], p[4], p[5], p[6])); x = p[0]
    return path[::-1]


def cmd_path(root, a, b):
    nodes, edges = load(root)
    ha, hb = find(nodes, a), find(nodes, b)
    if not ha or not hb:
        return print("one of the names not found in graph")
    best = None
    for x in ha[:4]:
        for y in hb[:4]:
            if x != y:
                pp = bfs_path(nodes, edges, x, y)
                if pp and (best is None or len(pp) < len(best[2])):
                    best = (x, y, pp)
    if not best:
        return print("no connection found")
    ha, p = [best[0]], best[2]
    print(fmt(nodes, ha[0]))
    for s, d, rel, dr, tag, conf, f, l in p:
        print(f"  {dr}{rel}{dr if dr == '->' else ''} {fmt(nodes, d)}  [{tag[:3]} {conf}] {f}:{l}")


def cmd_impact(root, q):
    nodes, edges = load(root)
    hits = find(nodes, q)
    if not hits:
        return print("not found")
    rev = collections.defaultdict(list)
    for s, d, rel, *_ in edges:
        if rel != "defines":
            rev[d].append(s)
    start = hits[0]
    seen, dq, depth = {start: 0}, collections.deque([start]), {}
    while dq:
        x = dq.popleft()
        for y in rev[x]:
            if y not in seen:
                seen[y] = seen[x] + 1; dq.append(y)
    files = sorted({nodes[n]["file"] for n in seen if n != start})
    risk = "HIGH" if len(files) > 10 else "MED" if len(files) > 3 else "LOW"
    print(f"Impact of {fmt(nodes, start)}\nRisk: {risk} ({len(files)} files depend on it)")
    for n, dd in sorted(seen.items(), key=lambda x: x[1])[1:30]:
        print(f"  hop {dd}: {fmt(nodes, n)}")


def main():
    a = sys.argv[1:]
    if not a or a[0] in ("-h", "--help"):
        return print(__doc__)
    c = a[0]
    root = "."
    if c == "build":
        build(a[1] if len(a) > 1 else ".")
    elif c in ("query", "explain") and len(a) > 1:
        cmd_query(root, a[1])
    elif c == "path" and len(a) > 2:
        cmd_path(root, a[1], a[2])
    elif c == "impact" and len(a) > 1:
        cmd_impact(root, a[1])
    elif c == "html":
        p_ = os.path.join(root, "graphify-out", "graph.json")
        if not os.path.exists(p_):
            sys.exit("No graph yet. Run: python graphify_lite.py build .")
        d_ = json.load(open(p_))
        rp = os.path.join(root, "graphify-out", "GRAPH_REPORT.md")
        rep_ = open(rp).read() if os.path.exists(rp) else ""
        hp = write_html(os.path.join(root, "graphify-out"), d_["nodes"], [tuple(e) for e in d_["edges"]], d_.get("meta", {}), rep_)
        print(f"Saved {hp}\nOpen: termux-open {hp}   (or: cd graphify-out && python -m http.server 8000)")
    elif c == "report":
        print(open(os.path.join(root, "graphify-out", "GRAPH_REPORT.md")).read())
    else:
        print(__doc__)


if __name__ == "__main__":
    main()
