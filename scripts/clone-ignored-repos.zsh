#!/usr/bin/env zsh
#
# clone-ignored-repos.zsh
#
# Scan this monorepo for .gitignore files and clone any repos referenced
# by paired lines of the form:
#
#     # remote: https://github.com/user/repo-name.git
#     repo-name/
#
#     # remote: git@github.com:user/repo-name.git
#     repo-name/
#
# Each entry is a "# remote: <url>" comment line followed *immediately* (no
# blank line, no other line between) by a "<name>/" directory pattern. This
# layout matches how git itself parses .gitignore — comments must occupy
# their own line, and trailing inline comments on patterns are not honoured.
# The URL is whatever non-empty token follows "# remote: "; no URL-format
# validation is done.
#
# For each such entry, `git clone <url> <repo-name>` is run in the directory
# containing that .gitignore.
#
# Traversal rules:
#   - Starts at the given root (defaults to $PWD).
#   - The root directory's .gitignore is always processed, even though the
#     root itself is a git repo.
#   - Any *other* directory that is itself a git repo (has a sibling .git
#     entry) is skipped entirely — we never descend into child repos.
#
# Behaviour:
#   - Idempotent: if <repo-name> already exists, prints "<repo-name> already
#     exists." and skips.
#   - Authentication failures are reported to stderr and do not abort the run.
#   - Other clone failures are reported to stderr and do not abort the run.
#   - .gitignore files are never modified.
#
# Usage:
#     ./clone-ignored-repos.zsh [path-to-monorepo-root]

emulate -L zsh
setopt NO_UNSET PIPE_FAIL EXTENDED_GLOB
# Intentionally NOT ERR_EXIT — we want to continue after individual failures.

# ---------------------------------------------------------------------------
# Preflight

if ! command -v git >/dev/null 2>&1; then
  print -u2 -- "Error: git is not installed or not in PATH."
  exit 1
fi

# ---------------------------------------------------------------------------
# Helpers

# Walk the tree from $1, printing paths of .gitignore files one per line.
# Prunes any subdirectory (other than the starting root) that contains a
# .git entry, so we never recurse into child repos.
#
#   $1 - directory to walk
#   $2 - "true" if this is the starting root, else "false"
function collect_gitignores() {
  local dir="$1"
  local is_root="$2"

  if [[ "$is_root" != "true" && -e "$dir/.git" ]]; then
    return
  fi

  if [[ -f "$dir/.gitignore" ]]; then
    print -r -- "$dir/.gitignore"
  fi

  # (D) include dotdirs, (N) nullglob, (/) directories only.
  local sub
  for sub in "$dir"/*(DN/); do
    [[ "${sub:t}" == ".git" ]] && continue
    collect_gitignores "$sub" "false"
  done
}

# If the line is a "# remote: <url>" comment, print the URL on stdout (with
# trailing whitespace stripped). Otherwise print nothing.
function parse_remote_comment() {
  local line="${1%$'\r'}"   # strip any trailing CR (CRLF safety)

  if [[ "$line" =~ '^[[:space:]]*#[[:space:]]+remote:[[:space:]]+(.+)$' ]]; then
    local url="${match[1]%%[[:space:]]##}"
    [[ -n "$url" ]] && print -r -- "$url"
  fi
}

# If the line is a bare "<n>/" directory pattern (optional surrounding
# whitespace, trailing slash required), print the bare name. Otherwise
# print nothing. Negations, wildcards, and nested paths intentionally don't
# match — they're ordinary gitignore content the script leaves alone.
function parse_dir_pattern() {
  local line="${1%$'\r'}"

  if [[ "$line" =~ '^[[:space:]]*([A-Za-z0-9_][A-Za-z0-9._-]*)/[[:space:]]*$' ]]; then
    print -r -- "${match[1]}"
  fi
}

# Return 0 if the given git output looks like an authentication failure.
# Covers both HTTPS credential errors and SSH publickey errors, plus the
# "Repository not found" that GitHub returns for private repos accessed
# without sufficient credentials.
function is_auth_failure() {
  local out="${1:l}"   # lowercase
  [[ "$out" == *"authentication failed"*                       ]] && return 0
  [[ "$out" == *"permission denied"*                           ]] && return 0
  [[ "$out" == *"could not read username"*                     ]] && return 0
  [[ "$out" == *"could not read password"*                     ]] && return 0
  [[ "$out" == *"invalid username or password"*                ]] && return 0
  [[ "$out" == *"repository not found"*                        ]] && return 0
  [[ "$out" == *"access denied"*                               ]] && return 0
  [[ "$out" == *"publickey"*                                   ]] && return 0
  [[ "$out" == *"please make sure you have the correct access"* ]] && return 0
  [[ "$out" == *"terminal prompts disabled"*                   ]] && return 0
  return 1
}

# Indent multi-line text by 4 spaces for nicer error output.
function indent() {
  print -r -- "    ${1//$'\n'/$'\n'    }"
}

# ---------------------------------------------------------------------------
# Main

function main() {
  local root="${1:-$PWD}"
  root="${root:A}"   # absolute, canonical

  if [[ ! -d "$root" ]]; then
    print -u2 -- "Error: '$root' is not a directory."
    return 1
  fi

  local -i total=0 cloned=0 existed=0 auth_failed=0 other_failed=0

  local -a gitignores
  gitignores=( ${(f)"$(collect_gitignores "$root" "true")"} )

  if (( ${#gitignores} == 0 )); then
    print -- "No .gitignore files found under $root."
    return 0
  fi

  local gitignore dir rel_dir line pending_url repo_name url target output
  local -i rc

  for gitignore in $gitignores; do
    dir="${gitignore:h}"
    rel_dir="${dir#$root}"
    rel_dir="${rel_dir#/}"
    [[ -z "$rel_dir" ]] && rel_dir="."

    # Read line-by-line, tracking a "pending URL" from any "# remote: <url>"
    # comment so the immediately-following "<n>/" pattern can use it.
    # Strict adjacency — anything else between the two breaks the pairing.
    # The `|| [[ -n $line ]]` clause handles a final line missing a newline.
    pending_url=""
    while IFS= read -r line || [[ -n "$line" ]]; do
      # Case 1: a "# remote: <url>" comment — remember its URL.
      url=$(parse_remote_comment "$line")
      if [[ -n "$url" ]]; then
        pending_url="$url"
        continue
      fi

      # Case 2: a "<n>/" directory pattern. If a URL is pending from the
      # line right above, this is a clone-eligible entry; otherwise it's
      # an ordinary ignore pattern and we leave it alone.
      repo_name=$(parse_dir_pattern "$line")
      if [[ -n "$repo_name" && -n "$pending_url" ]]; then
        url="$pending_url"
        pending_url=""
        target="$dir/$repo_name"

        (( total++ ))

        if [[ -e "$target" ]]; then
          print -- "$repo_name already exists."
          (( existed++ ))
          continue
        fi

        # Run the clone. GIT_TERMINAL_PROMPT=0 prevents an interactive
        # credential prompt from hanging the script on private HTTPS repos.
        output=$(GIT_TERMINAL_PROMPT=0 git clone -- "$url" "$target" 2>&1)
        rc=$?

        if (( rc == 0 )); then
          print -- "Cloned '$repo_name' into $rel_dir/ from $url"
          (( cloned++ ))
          continue
        fi

        # Clean up any empty target directory git may have left behind.
        if [[ -d "$target" && -z "$(command ls -A "$target" 2>/dev/null)" ]]; then
          rmdir "$target" 2>/dev/null
        fi

        if is_auth_failure "$output"; then
          print -u2 -- "⚠️  Could not clone '$repo_name' (at $rel_dir/) from $url — authentication failed. Skipping and moving on."
          (( auth_failed++ ))
        else
          print -u2 -- "⚠️  Could not clone '$repo_name' (at $rel_dir/) from $url. Git reported:"
          indent "$output" >&2
          (( other_failed++ ))
        fi
        continue
      fi

      # Case 3: anything else — blank line, regular comment, plain ignore
      # pattern, or a directory pattern with no URL pending. Strict adjacency
      # is broken, so drop any pending URL.
      pending_url=""
    done < "$gitignore"
  done

  print -- ""
  print -- "── Summary ──────────────────────────"
  print -- "  Entries processed:  $total"
  print -- "  Newly cloned:       $cloned"
  print -- "  Already existed:    $existed"
  print -- "  Auth failures:      $auth_failed"
  print -- "  Other failures:     $other_failed"

  (( auth_failed > 0 || other_failed > 0 )) && return 1
  return 0
}

main "$@"
