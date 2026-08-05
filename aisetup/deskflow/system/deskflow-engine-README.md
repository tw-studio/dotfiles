---
name: deskflow-engine-README.md
version: 00.01
updated: 2026-08-02
---

# Deskflow Engine

A small deterministic script — one file, no dependencies beyond Node.js (built-in fs and path modules only) — that handles all bookkeeping that no AI agent should be doing. Agents exercise judgment; this script exercises mechanics. User never runs it directly; it is invoked through `just` commands (see `justfile` at the workspace root).

## What It Does

| Verb | Just command | What happens |
|---|---|---|
| `fresh` | `just desk-fresh` | Reads EPICS.md, plan files, and event files; instantiates due Operations steps for the day based on cadence tags; carries over unfinished one-offs from yesterday; consolidates yesterday's DESK stamps into one archive file; stamps a new DESK; prints the archive path and a clickable link to the new DESK. |
| `watch` | `just desk-watch` | Watches the live DESK file, plan files, and event files for changes; on any change, diffs the DESK against its snapshot to detect checkbox flips and turns them into done events; re-renders TASKBOARD.md; saves a snapshot when the board content changed. Debounced to ~2 seconds. Runs in a tmux pane. |
| `render` | `just desk-render` | One-shot: reads plan files and all event files, regenerates TASKBOARD.md. |
| `archive` | `just desk-archive` | Consolidates the current day's DESK stamps into one `desk/archive/DESK_{yymmdd}.md`. |
| `snapshot-cleanup` | `just desk-snapshot-cleanup` | Keeps all snapshots from the past 7 days; for older days keeps one per day (the last of that day) and deletes the rest. |

## What It Does Not Do

Judgment. Planning. Elevating wording. Reading natural language. Making decisions. Anything that requires a language model. Those belong to agents: /deskflow, /taskflow-planner, and the Epicflow drivers. The engine's entire scope is file reading, diffing, checkbox-to-event translation, template rendering, timestamping, and cleanup.

## How It Fits

```
User ──edits──▶ DESK ─────┐
                           │   ┌────────────────────┐
Planner sessions ──▶ PLAN ─┤──▶│  deskflow-engine    │──▶ TASKBOARD.md ──▶ Locked Preview
  (structure, slow)        │   │  (sole renderer of  │
Agent sessions ──▶ PULSE ──┘   │   all generated     │──▶ DESK stamps (via fresh)
  (events, fast,               │   views; sole        │
   append-only)                │   mechanical         │──▶ Snapshots
                               │   propagator)        │
                               └────────────────────┘
```

Three layers, one engine: Plan files carry structure (state-free). Pulse files carry events (append-only, one writer each). Board and DESK stamps are generated views — the engine is their sole writer, so no agent conflicts are possible by construction.

## Build Status

Skeleton built: verb dispatch and invocation path work end to end; each verb reports itself honestly as not yet implemented. Logic lands after the formats survive first real use on the work machine. Formats it will parse are frozen in the fundamentals (§5, §6, §7). This README is the spec it will be built against.

## Location

`deskflow/system/deskflow-engine.js`. The justfile points to it via `node`.
