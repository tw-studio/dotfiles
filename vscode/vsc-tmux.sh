#!/bin/bash
MD5=$(command -v md5 || command -v md5sum)
SESSION="vscode`pwd | $MD5 | cut -d' ' -f1`"
#if ! command -v tmux > /dev/null; then
if [[ ! -f "/opt/homebrew/bin/tmux" && ! -f "/usr/bin/tmux" && ! -f "/usr/local/bin/tmux" ]]; then
  echo "tmux not found. Starting zsh in 3 seconds..."
  sleep 3
  zsh -l
else
  TMUX=$(command -v /opt/homebrew/bin/tmux || command -v /usr/local/bin/tmux || command -v /usr/bin/tmux)
  TMUX_IN_VSCODE=1 TERM=screen-256color $TMUX attach-session -d -t $SESSION || TMUX_IN_VSCODE=1 TERM=screen-256color $TMUX new-session -s $SESSION
  #tmux attach-session -d -t ${PWD##*/} || tmux attach-session -d -t $SESSION || tmux new-session -s $SESSION
fi
