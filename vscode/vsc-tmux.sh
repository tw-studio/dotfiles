#!/bin/bash
MD5=$(command -v md5 || command -v md5sum)
SESSION="vscode`pwd | $MD5 | cut -d' ' -f1`"
#if ! command -v tmux > /dev/null; then
if [[ ! -f "/usr/bin/tmux" && ! -f "/usr/local/bin/tmux" ]]; then
  echo "tmux not found. Starting zsh in 3 seconds..."
  sleep 3
  zsh -l
else
  TMUX=$(command -v /usr/local/bin/tmux || command -v /usr/bin/tmux)
  TERM=screen-256color-bce $TMUX attach-session -d -t $SESSION || TERM=screen-256color-bce $TMUX new-session -s $SESSION
  #tmux attach-session -d -t ${PWD##*/} || tmux attach-session -d -t $SESSION || tmux new-session -s $SESSION
fi
