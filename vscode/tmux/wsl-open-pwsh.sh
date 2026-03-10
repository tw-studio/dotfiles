#!/bin/bash
set -e

if ! command -v wslpath >/dev/null; then
  echo "This script is intended to be run in WSL. Starting bash in 3 seconds..."
  sleep 3
  exec bash --login
fi

WINPWD=$(wslpath -w "$PWD")
PWSH_EXE="/mnt/c/Program Files/PowerShell/7/pwsh.exe"

if [[ ! -f "$PWSH_EXE" ]]; then
  echo "PowerShell not found at $PWSH_EXE"
  sleep 3
  exec bash --login
fi

exec "$PWSH_EXE" -NoLogo -NoExit -WorkingDirectory "$WINPWD"
