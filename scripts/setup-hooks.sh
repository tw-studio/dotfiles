#!/bin/bash
#
# setup-hooks.sh
# Symlinks hooks from scripts/hooks into .git/hooks

# |1| Get script and project root directory locations

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PROJECT_ROOT=$(git -C "${SCRIPTS_DIR}" rev-parse --show-toplevel 2> /dev/null)
if [[ -z "$PROJECT_ROOT" ]]; then
  echo "Error: Could not determine the project root directory. Are you in a Git repository?"
  exit 1
fi

# |2| Validate the required directories

HOOKS_SRC="${PROJECT_ROOT}/scripts/hooks"
if [[ ! -d "${HOOKS_SRC}" ]]; then
  echo "Error: Hooks source directory does not exist: ${HOOKS_SRC}"
  exit 1
fi
HOOKS_DEST="${PROJECT_ROOT}/.git/hooks"
if [[ ! -d "${HOOKS_DEST}" ]]; then
  mkdir -p "${HOOKS_DEST}"
fi

# |3| Symlink executable hooks scripts into .git/hooks

for hook in "${HOOKS_SRC}"/*; do
  hook_name=$(basename "${hook}")
  if [[ -x "${hook}" ]]; then
    ln -sf "${hook}" "${HOOKS_DEST}/${hook_name}"
    echo "Symlinked hook: ${hook_name}"
  else
    echo "Warning: Skipping non-executable hook: ${hook_name}"
  fi
done
