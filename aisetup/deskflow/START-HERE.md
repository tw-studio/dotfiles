# Deskflow — Start Here

Setup and first-run guide. Read this once, do the steps, then you are working in the system.

## Prerequisites

- **Node.js** — any recent version; the engine uses built-in modules only.
- **just** — the command runner; already installed if you use justfiles.
- **VS Code** with **GitHub Copilot**, or **Claude** — the skills work with both.
- **Git** — the system commits its own artifacts; a repo must exist.

## Install

1. **Unzip at your workspace root.** Two folders land: `deskflow/` (the system) and `claude-skills/` (four skills: deskflow, deskflow-open, deskflow-self-improver, taskflow-planner). Copy the four folders inside `claude-skills/` into your `.claude/skills/`, beside your existing skills, then delete the now-empty `claude-skills/`. It ships visible rather than as a dotfolder so no unzip tool hides it from you.

2. **Add the just recipes to your workspace justfile.** Open `deskflow/system/.proposals/04.02-justfile-recipes.md` and paste the block into your workspace-level justfile. Adjust the `engine` path only if `deskflow/` sits somewhere other than directly under the workspace root.

3. **Commit.** `git add deskflow/ .claude/skills/ && git commit -m "Install Deskflow"`

That is the whole install. No epic files to fill, no folders to create — the system builds those from what you write next.

## First Run

From your workspace root, in order:

**1. Stamp your first desk.**

```
just desk-fresh
```

You get a clickable link to a fresh DESK file. Click it. It opens as a blank scaffold: empty Operations Today, empty Epics Today, Waiting, One-offs, Done Today, Meetings. This emptiness is correct — the system knows nothing yet.

**2. Braindump into the DESK.** This is the real onboarding, and it is just you writing on your page. Under Epics Today, write your epics as checklist lines. Nest outcomes, tasks, and steps under whichever ones you feel like sketching. Drop agent ideas as `/slash-names` at line ends. Add attributes as `[tag]:` children. Write as much or as little as the moment produces — one bare epic name is enough to start, and twenty deep trees are equally welcome. Rough wording is expected; elevating it is the system's job, not yours.

**3. Flow it.** Open the chat pane and run the **deskflow** skill:

```
/deskflow
```

It reads your braindump, registers your epics (creating EPICS.md and the epic folders itself), elevates your rough wording with every change shown before-and-after, asks only what it genuinely cannot infer, and spawns one session per epic. You get one kickoff report and a sessions list that fills with your epics by name.

**4. Set up the live view.**

In a tmux pane you keep visible:

```
just desk-watch
```

Then Ctrl+P → `TASKBOARD` → open as preview → drag the tab down into a horizontal strip → lock it. The board updates within two seconds of any checkbox flip or session event.

From here, the day runs as the walkthrough describes (`deskflow/system/.examples/03.00-WALKTHROUGH.md`): sessions signal you when your move is ready, you flit between them spending small judgments, and the board keeps every epic's state visible at a glance.

## What To Expect First Week

- Most epic sessions open by asking you to describe the epic, because no plans exist yet. That is the system working — planning is the session's first job for an unplanned epic, and it interviews at your altitude, not with a questionnaire.
- The board is sparse until plan files with real tasks start landing in epic folders.
- Everything gets richer with each `/deskflow` run as plans, events, and artifacts accumulate.

## Smoke Tests

Before trusting the full flow, confirm on your machine:

1. **`just desk-fresh`** — you get a DESK and a TASKBOARD.
2. **`just desk-watch`** — flip a checkbox in the desk; the board changes within seconds.
3. **CLI sessions appear in the Chat view** — start a Copilot CLI session and confirm it lists.
4. **Non-interactive mode and resume-by-id** — needed for background sessions.
5. **Archived-session revival** — message an archived session and see if it reappears (nice-to-have).

## Files You Care About

| # | File | What it is | You edit it? |
|---|---|---|---|
| 1 | `deskflow/desk/DESK_*.md` | Your daily working surface | Yes — this is your page |
| 2 | `deskflow/TASKBOARD.md` | Live radar, open in locked preview | Never — the engine writes it |
| 3 | `deskflow/epics/EPICS.md` | Epic registry | Never — system-maintained; declare and reorder epics in the DESK |
| 4 | `deskflow/system/CRAFT-LIBRARY.md` | Shared instructions all agents follow | Rarely — through self-improvement or directly |
| 5 | `deskflow/system/SYSTEM-FUNDAMENTALS.md` | Structural law | Rarely — when standards need updating |
| 6 | `.claude/skills/*/SKILL.md` | Agent charters | When tuning agent behavior |

Everything in `system/.proposals/` and `system/.examples/` is planning and reference material for you and for fresh AI sessions resuming this effort. You never need to open them to use the system.
