---
name: justfile-recipes.md
version: 04.02
updated: 2026-08-03
status: proposal — paste these recipes into your workspace-level justfile
---

# Deskflow Just Recipes

Copy the block below into your workspace justfile. Shell-neutral by design: every recipe is a bare `node` invocation, so the identical block works in your Mac zsh workspace and your Windows 11 PowerShell workspace with no `[script]` annotations and no per-OS variants. Adjust the `engine` path only if `deskflow/` sits somewhere other than directly under the workspace root.

```just
# Deskflow — just commands
# Run from the workspace root (parent of deskflow/).

################################################################
#
# MARK: Deskflow
#
################################################################

engine := "node deskflow/system/deskflow-engine.js"

################################################################
# > MARK: desk-doctor: Check prerequisites (node, git, just, copilot, code)
################################################################
desk-doctor:
    {{engine}} doctor

################################################################
# > MARK: desk-fresh: Stamp a fresh desk, archive yesterday's
################################################################
desk-fresh:
    {{engine}} fresh

################################################################
# > MARK: desk-open: Open latest DESK file in VS Code
################################################################
desk-open:
    {{engine}} open

################################################################
# > MARK: desk-watch: Re-renders taskboard on any desk/event change
################################################################
desk-watch:
    {{engine}} watch

################################################################
# > MARK: desk-render: One-shot board render
################################################################
desk-render:
    {{engine}} render

################################################################
# > MARK: desk-archive: Consolidate today's desk stamps into one archive file
################################################################
desk-archive:
    {{engine}} archive

################################################################
# > MARK: desk-snapshot-cleanup: Clean up old board snapshots (keeps one per day after 7 days)
################################################################
desk-snapshot-cleanup:
    {{engine}} snapshot-cleanup
```

**Notes:**

1. `desk-open` now runs through the engine's `open` verb, which finds the latest DESK and launches VS Code itself — this is what removed the last shell-specific recipe.
2. `code` must be on PATH on both machines: standard on Windows installs; on Mac, run "Shell Command: Install 'code' command in PATH" from the VS Code command palette once if it is not already.
3. Recommended once per repo for two-OS work: add `* text=auto` to `.gitattributes` so line endings stay clean between machines.
