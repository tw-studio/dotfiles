#!/bin/bash
# vsc-tmux-pwsh.sh

################################################################
# > MARK: Ensure systemd tmux.service (with keepalive)
################################################################

TMUX_SERVICE="$HOME/.config/systemd/user/tmux.service"
if [[ ! -f "$TMUX_SERVICE" ]]; then
  mkdir -p "$(dirname "$TMUX_SERVICE")"
  cat > "$TMUX_SERVICE" << 'EOF'
[Unit]
Description=tmux server

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/tmux new-session -d -s _keepalive
ExecStop=/usr/bin/tmux kill-server

[Install]
WantedBy=default.target
EOF
  systemctl --user daemon-reload
  systemctl --user enable --now tmux
fi

# If service exists but isn't running, start it
if ! systemctl --user is-active --quiet tmux; then
  systemctl --user start tmux
fi

################################################################
# > MARK: VSCode tmux session logic
################################################################

MD5=$(command -v md5 || command -v md5sum)
SESSION="vscodepwsh`pwd | $MD5 | cut -d' ' -f1`"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PWSH_SCRIPT="$SCRIPT_DIR/wsl-open-pwsh.sh"

if [[ ! -f "/opt/homebrew/bin/tmux" && ! -f "/usr/bin/tmux" && ! -f "/usr/local/bin/tmux" ]]; then
  echo "tmux not found. Starting zsh in 3 seconds..."
  sleep 3
  zsh -l
else
  TMUX_BIN=$(command -v /opt/homebrew/bin/tmux || command -v /usr/local/bin/tmux || command -v /usr/bin/tmux)

  if [[ ! -x "$PWSH_SCRIPT" ]]; then
    # Fallback: no pwsh script available
    if "$TMUX_BIN" has-session -t "$SESSION" 2>/dev/null; then
      TERM=screen-256color-bce "$TMUX_BIN" new-session -t "$SESSION"
    else
      TERM=screen-256color-bce "$TMUX_BIN" new-session -s "$SESSION"
    fi
  else
    # Launch PowerShell in WSL
    if "$TMUX_BIN" has-session -t "$SESSION" 2>/dev/null; then
      TERM=screen-256color-bce "$TMUX_BIN" new-session -t "$SESSION"
    else
      TERM=screen-256color-bce "$TMUX_BIN" new-session -d -s "$SESSION" -c "$PWD" "zsh -lc '$PWSH_SCRIPT'"

      "$TMUX_BIN" set-option -t "$SESSION" -g default-command "zsh -lc '$PWSH_SCRIPT'"
      "$TMUX_BIN" set-window-option -t "$SESSION:1" automatic-rename off
      "$TMUX_BIN" rename-window -t "$SESSION:1" "pwsh"
      "$TMUX_BIN" set-hook -t "$SESSION" after-new-window "rename-window pwsh"

      TERM=screen-256color-bce "$TMUX_BIN" attach-session -t "$SESSION"
    fi
  fi
  # TMUX_IN_VSCODE=1 TERM=screen-256color $TMUX attach-session -d -t $SESSION || TMUX_IN_VSCODE=1 TERM=screen-256color $TMUX new-session -s $SESSION
  #tmux attach-session -d -t ${PWD##*/} || tmux attach-session -d -t $SESSION || tmux new-session -s $SESSION
fi
