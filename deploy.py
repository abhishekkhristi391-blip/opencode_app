#!/usr/bin/env python3
"""Termux me chalao:  python3 deploy.py "commit message" path1 path2 ...

Code ko git me push karta hai. Uske baad GitHub Actions automatically
APK build karta hai — Actions tab se download karo.

WHY EXPLICIT PATHS
------------------
Another agent session may be editing this same working tree at the same time.
`git add -A` cannot tell whose work is whose: it stages everything that
happened to change, which silently ships someone else's half-finished file
inside your commit and breaks CI for reasons you did not cause. So this script
takes the exact paths you changed, stages only those, shows you the staged
list, and refuses to commit if the index contains anything else.

Rules this enforces:
  * never `git add -A`, never `git add .`, never `git commit -a`
  * zero paths is an error, not a "commit everything" fallback
  * every staged file must be inside one of the paths you passed
"""
import os
import posixpath
import subprocess
import sys
import webbrowser
from datetime import datetime

REPO_DIR = os.path.dirname(os.path.abspath(__file__))
REMOTE = "https://github.com/abhishekkhristi391-blip/opencode_app.git"
BRANCH = "main"
ACTIONS_URL = f"https://github.com/abhishekkhristi391-blip/opencode_app/actions"

BOLD, DIM, GRN, RED, YLW, RST = "\033[1m", "\033[2m", "\033[32m", "\033[31m", "\033[33m", "\033[0m"

USAGE = 'python3 deploy.py "commit message" path1 path2 ...'


def run(cmd, check=True):
    print(f"{DIM}$ {' '.join(cmd)}{RST}")
    r = subprocess.run(cmd, cwd=REPO_DIR, text=True, capture_output=True)
    out = (r.stdout + r.stderr).strip()
    if out:
        print(out)
    if check and r.returncode != 0:
        print(f"\n{RED}Error aaya, upar ka message dekho.{RST}")
        low = out.lower()
        if "authentication" in low or "denied" in low or "could not read" in low:
            print(f"Login fix:  {BOLD}gh auth login && gh auth setup-git{RST}")
        sys.exit(1)
    return r


def fail(msg):
    print(f"\n{RED}{BOLD}Ruka hua: {msg}{RST}")
    sys.exit(1)


def norm(p):
    """Repo-relative, posix, no leading ./ — the same shape git reports."""
    p = p.strip().replace(os.sep, "/")
    if os.path.isabs(p):
        p = os.path.relpath(p, REPO_DIR).replace(os.sep, "/")
    p = posixpath.normpath(p)
    return p[2:] if p.startswith("./") else p


def allowed(staged, paths):
    """Is `staged` one of `paths`, or inside one of them (a passed directory)?"""
    for p in paths:
        if staged == p:
            return True
        if staged.startswith(p.rstrip("/") + "/"):
            return True
    return False


def staged_files():
    """Everything currently staged, i.e. index vs HEAD."""
    out = run(["git", "diff", "--cached", "--name-only"], check=False).stdout
    return sorted({line.strip() for line in out.splitlines() if line.strip()})


def check_paths(paths):
    for raw in paths:
        p = norm(raw)
        if not p or p == ".":
            fail(f"'{raw}' is not a usable path.")
        full = os.path.join(REPO_DIR, p)
        if not os.path.exists(full):
            import difflib
            tracked = run(["git", "ls-files"], check=False).stdout.split()
            near = difflib.get_close_matches(p, tracked, n=3, cutoff=0.6)
            hint = ("\n  Did you mean: " + ", ".join(near)) if near else ""
            fail(f"'{p}' does not exist in the repo — nothing was staged.{hint}")
        if os.path.isdir(full):
            contents = [
                os.path.relpath(os.path.join(root, f), REPO_DIR).replace(os.sep, "/")
                for root, _, files in os.walk(full)
                for f in files
            ]
            if not contents:
                fail(f"'{raw}' is an empty directory — nothing to commit.")


def main():
    if not os.path.isdir(REPO_DIR):
        print(f"{RED}Folder nahi mila: {REPO_DIR}{RST}")
        print("Setup chalao:  bash setup.sh")
        sys.exit(1)

    args = sys.argv[1:]
    if args and args[0] in ("-h", "--help"):
        print(__doc__)
        print(f"\nUsage: {USAGE}")
        return

    if len(args) < 2:
        print(f"{RED}{BOLD}Paths zaroori hain.{RST}")
        print("Is script sirf wahi stage karta hai jo tumne change kiya —")
        print("isliye 'kuch nahi' ka koi fallback nahi hai. Na deoge to kuch nahi hoga.")
        print(f"\nUsage: {USAGE}")
        print(f"{DIM}Example: python3 deploy.py \"fix(prompts): show full command\" "
              f"lib/ui/prompts.dart lib/l10n/strings.dart{RST}")
        sys.exit(1)

    msg = args[0].strip()
    if not msg:
        fail("commit message khali hai.")
    paths = []
    for raw in args[1:]:
        p = norm(raw)
        if p and p not in paths:
            paths.append(p)

    if not os.path.isdir(os.path.join(REPO_DIR, ".git")):
        run(["git", "init"])
    run(["git", "branch", "-M", BRANCH])

    if run(["git", "remote", "get-url", "origin"], check=False).returncode == 0:
        run(["git", "remote", "set-url", "origin", REMOTE])
    else:
        run(["git", "remote", "add", "origin", REMOTE])

    print(f"\n{BOLD}Staging sirf ye paths:{RST}")
    for p in paths:
        print(f"  {p}")
    check_paths(paths)

    junk = [p for p in ("build", ".dart_tool", ".idea", "android/.gradle", "local.properties")
            if os.path.exists(os.path.join(REPO_DIR, p))]
    if any(allowed(j, paths) for j in junk):
        print(f"{YLW}Note: build artifacts me se kuch stage ho rahe hain.{RST}")

    # Fail fast if the index was already dirty from someone else's work.
    pre = [f for f in staged_files() if not allowed(f, paths)]
    if pre:
        fail("index me pehle se ye staged hain, jo tumne pass nahi kiye:\n  "
             + "\n  ".join(pre)
             + "\nUnhe dekh lo (git diff --cached), phir `git restore --staged <file>` "
               "se hatao, ya unhe bhi paths me shamil karo.")

    run(["git", "add", "--"] + paths)

    staged = staged_files()
    stray = [f for f in staged if not allowed(f, paths)]
    if stray:
        fail("ye staged ho gaye tumhare paths ke bahar — commit nahi kar raha:\n  "
             + "\n  ".join(stray)
             + "\nKisi aur session ka kaam hai. `git restore --staged .` se saaf "
               "karke dobara chalao.")

    print(f"\n{BOLD}Staged files ({len(staged)}):{RST}")
    for f in staged:
        print(f"  {f}")

    if not staged:
        print(f"\n{YLW}In paths me koi change nahi tha. Sirf push kar raha hu.{RST}")
    else:
        run(["git", "commit", "-m", msg])
        print(f"{GRN}Commit ho gaya.{RST}")

    push = run(["git", "push", "-u", "origin", BRANCH], check=False)
    if push.returncode != 0:
        sys.exit(1)

    print()
    print(f"{GRN}{BOLD}Deploy ho gaya!{RST} Actions tab me build chal raha hai:")
    print(f"  {ACTIONS_URL}")
    print(f"{DIM}(2-4 minute lagenge. Uske baad 'opencode-apk' artifact download karo.){RST}")

    try:
        from shutil import which
        if which("xdg-open"):
            webbrowser.open(ACTIONS_URL)
    except Exception as e:
        print(f"Failed to open browser: {e}")


if __name__ == "__main__":
    main()
