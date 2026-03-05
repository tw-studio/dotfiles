@echo off
wsl bash -c "exec bash \"$(wslpath '%~dp0')vsc-tmux-pwsh.sh\""
