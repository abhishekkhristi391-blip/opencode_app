#!/usr/bin/env python3
"""
graphify_lite.py - single-file code graph tool (stdlib only, phone friendly)

  python graphify_lite.py build  [folder]
  python graphify_lite.py query   "word"        # find nodes + 2-hop neighbours
  python graphify_lite.py path    "A" "B"       # shortest connection A -> B
  python graphify_lite.py explain "X"           # who calls X, what X calls
  python graphify_lite.py impact  "X"           # everything that depends on X
  python graphify_lite.py report                # print GRAPH_REPORT.md

Output goes to <folder>/graphify-out/: graph.json, graph.md, GRAPH_REPORT.md
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
    with open(os.path.join(out, "graph.json"), "w") as fh:
        json.dump({"nodes": g.nodes, "edges": g.edges}, fh)
    with open(os.path.join(out, "graph.md"), "w") as fh:
        for s, d, rel, tag, conf, f, l in sorted(g.edges):
            t = tag if tag == "EXTRACTED" else f"INFERRED {conf}"
            fh.write(f"{s} --{rel}--> {d} [{t}] {f}:{l}\n")
    rep = report(g, deg, sccs, communities, orphans, len(files_list))
    with open(os.path.join(out, "GRAPH_REPORT.md"), "w") as fh:
        fh.write(rep)
    print(rep)
    print(f"\nSaved: {out}/ (graph.json, graph.md, GRAPH_REPORT.md)")


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
    elif c == "report":
        print(open(os.path.join(root, "graphify-out", "GRAPH_REPORT.md")).read())
    else:
        print(__doc__)


if __name__ == "__main__":
    main()
