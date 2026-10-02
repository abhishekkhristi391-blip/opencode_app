#!/data/data/com.termux/files/usr/bin/bash
# OpenCode Client — Termux setup
#   bash ~/opencode_chat/setup.sh
#
# Kaam karta hai:
#   1. Server start script banata hai
#   2. Termux:Boot se auto-start set karta hai (optional)
#   3. Sanity check

set -u

DIR="${HOME}/opencode_chat"
PORT="${OPENCODE_PORT:-4096}"
PROJECT_DIR="${1:-$HOME/project}"
BOLD=$'\033[1m'; DIM=$'\033[2m'; GRN=$'\033[32m'; RED=$'\033[31m'; YLW=$'\033[33m'; RST=$'\033[0m'

say()  { printf '%s\n' "$*"; }
ok()   { printf '%s✔%s %s\n' "$GRN" "$RST" "$*"; }
warn() { printf '%s!%s %s\n' "$YLW" "$RST" "$*"; }
err()  { printf '%s✘%s %s\n' "$RED" "$RST" "$*"; }

say ""
say "${BOLD}OpenCode Client — setup${RST}"
say ""

# ---------------------------------------------------------------- opencode
if ! command -v opencode >/dev/null 2>&1; then
  err "opencode install nahi hai."
  say "  Install karo:  ${BOLD}npm install -g opencode-ai${RST}"
  say "  ya Termux me:  ${BOLD}pkg install opencode${RST}"
  exit 1
fi
ok "opencode $(opencode --version 2>/dev/null | head -1)"

# ---------------------------------------------------------------- start script
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/opencode-start" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
# opencode server background me chalao. Project dir: $PROJECT_DIR
PORT="\${OPENCODE_PORT:-$PORT}"
PIDFILE="\$HOME/.opencode-server.pid"
LOG="\$HOME/.opencode-server.log"

if [ -f "\$PIDFILE" ] && kill -0 "\$(cat "\$PIDFILE")" 2>/dev/null; then
  echo "Server already chal raha hai (pid \$(cat "\$PIDFILE")) on port \$PORT"
  exit 0
fi

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR" || exit 1
nohup opencode serve --hostname 127.0.0.1 --port "\$PORT" > "\$LOG" 2>&1 &
echo \$! > "\$PIDFILE"
sleep 2
echo "Server start: http://127.0.0.1:\$PORT  (log: \$LOG)"
EOF
chmod +x "$HOME/.local/bin/opencode-start"
ok "start script: ~/.local/bin/opencode-start"

cat > "$HOME/.local/bin/opencode-stop" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
PIDFILE="$HOME/.opencode-server.pid"
if [ -f "$PIDFILE" ]; then
  kill "$(cat "$PIDFILE")" 2>/dev/null && echo "Server band kar diya."
  rm -f "$PIDFILE"
else
  pkill -f "opencode serve" && echo "Server band kar diya." || echo "Koi server nahi tha."
fi
EOF
chmod +x "$HOME/.local/bin/opencode-stop"
ok "stop script:  ~/.local/bin/opencode-stop"

# ---------------------------------------------------------------- boot service
if [ -d "$PREFIX/termux-boot" ]; then
  mkdir -p "$PREFIX/termux-boot"
  cat > "$PREFIX/termux-boot/opencode-server" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
sleep 12
"$HOME/.local/bin/opencode-start"
EOF
  chmod +x "$PREFIX/termux-boot/opencode-server"
  ok "auto-start: Termux:Boot app install karo (boot pe khud chal jayega)"
else
  warn "Termux:Boot install nahi hai — auto-start skip kiya."
  say "  Install karne ke liye: ${BOLD}pkg install termux-boot${RST} + Termux:Boot app"
fi

# ---------------------------------------------------------------- start now
say ""
say "${DIM}Server abhi start kar raha hu…${RST}"
"$HOME/.local/bin/opencode-start"
sleep 3

if curl -s --max-time 4 "http://127.0.0.1:$PORT/global/health" >/dev/null 2>&1; then
  ok "server healthy: http://127.0.0.1:$PORT"
else
  warn "server abhi healthy nahi. Log dekho: cat ~/.opencode-server.log"
fi

say ""
say "${BOLD}Aage ka steps:${RST}"
say "  1. ${BOLD}python3 deploy.py${RST}   — code push + APK build (GitHub Actions)"
say "  2. GitHub Actions tab se APK download karke install karo"
say "  3. App me Settings → Server → http://127.0.0.1:$PORT"
say ""
say "${DIM}Tip: server hamesha usi project folder se start karo jise app me dekhna hai."
say "File browser, diff aur editor server ke current directory par kaam karte hain.${RST}"
say ""
