#!/usr/bin/env python3
"""Termux me chalao:  python3 deploy.py ["commit message"]

Code ko git me push karta hai. Uske baad GitHub Actions automatically
APK build karta hai — Actions tab se download karo.
"""
import os
import subprocess
import sys
import webbrowser
from datetime import datetime

REPO_DIR = os.path.expanduser("~/opencode_chat")
REMOTE = "https://github.com/abhishekkhristi391-blip/opencode_app.git"
BRANCH = "main"
ACTIONS_URL = f"https://github.com/abhishekkhristi391-blip/opencode_app/actions"

BOLD, DIM, GRN, RED, YLW, RST = "\033[1m", "\033[2m", "\033[32m", "\033[31m", "\033[33m", "\033[0m"


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


def main():
    if not os.path.isdir(REPO_DIR):
        print(f"{RED}Folder nahi mila: {REPO_DIR}{RST}")
        print("Setup chalao:  bash setup.sh")
        sys.exit(1)

    if len(sys.argv) > 1 and sys.argv[1] in ("-h", "--help"):
        print(__doc__)
        return

    msg = " ".join(sys.argv[1:]) or f"update {datetime.now():%Y-%m-%d %H:%M}"

    # Guard against committing junk.
    junk = [p for p in ("build", ".dart_tool", ".idea", "android/.gradle", "local.properties")
            if os.path.exists(os.path.join(REPO_DIR, p))]
    if junk:
        print(f"{YLW}Note: ye build artifacts bhi commit ho sakte hain: {', '.join(junk)}{RST}")

    if not os.path.isdir(os.path.join(REPO_DIR, ".git")):
        run(["git", "init"])
    run(["git", "branch", "-M", BRANCH])

    if run(["git", "remote", "get-url", "origin"], check=False).returncode == 0:
        run(["git", "remote", "set-url", "origin", REMOTE])
    else:
        run(["git", "remote", "add", "origin", REMOTE])

    run(["git", "add", "-A"])
    status = run(["git", "status", "--porcelain"], check=False).stdout.strip()
    if status:
        run(["git", "commit", "-m", msg])
        print(f"{GRN}Commit ho gaya.{RST}")
    else:
        print(f"{YLW}Koi naya change nahi, bas push kar raha hu.{RST}")

    push = run(["git", "push", "-u", "origin", BRANCH], check=False)
    if push.returncode != 0:
        sys.exit(1)

    print()
    print(f"{GRN}{BOLD}Deploy ho gaya!{RST} Actions tab me build chal raha hai:")
    print(f"  {ACTIONS_URL}")
    print(f"{DIM}(2-4 minute lagenge. Uske baad 'opencode-apk' artifact download karo.){RST}")

    if shutil_which("xdg-open"):
        try:
            webbrowser.open(ACTIONS_URL)
        except Exception:
            pass


def shutil_which(binary):
    from shutil import which
    return which(binary)


if __name__ == "__main__":
    main()
