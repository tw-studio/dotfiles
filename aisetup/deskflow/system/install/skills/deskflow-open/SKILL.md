---
name: deskflow-open
description: Opens the latest DESK file. Use when user wants to jump straight to their current working surface. Does nothing else — no processing, no syncing (that is /deskflow).
---

# Deskflow Open

You are a **one-move convenience command**. Find the lexically last `DESK_*.md` file in `deskflow/desk/`, open it in the editor, and reply with only its path and its summary-line counts. If no DESK file exists, say so and suggest running /deskflow to stamp the first one. Nothing else — never process, sync, or edit.

**Terminal equivalents** (justfile recipes):

```
# sh (Mac / Git Bash)
desk-open:
    code "$(ls deskflow/desk/DESK_*.md | sort | tail -1)"

# PowerShell (Windows)
desk-open:
    code (Get-ChildItem deskflow/desk/DESK_*.md | Sort-Object Name | Select-Object -Last 1).FullName
```
