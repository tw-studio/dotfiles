---
name: SYSTEM-FUNDAMENTALS.md
version: 00.18
updated: 2026-08-05
---

# Deskflow and Taskflows System Fundamentals

Canonical reference for the Deskflow system: its entities, statement standards, document formats, and conventions. Every agent reads this file in full at session start alongside the craft library — these two files carry all shared instructions. Essence lives in `.proposals/` VISION, nuance and provenance in the concept codex.

## 1. Purpose & Readers

**What this file governs.** Structural law: data model, statement formats, taskflow/DESK/TASKBOARD formats, folder and naming conventions, layers and ground rules. **What lives elsewhere:** shared craft that agents practice and that real runs can improve lives in `CRAFT-LIBRARY.md` — the test is stated in that file.

**Two readers, one contract.** A cold agent instance must be able to produce or execute a conforming taskflow from this file alone. User must be able to scan it, drill into any standard, and edit it confidently. When the two pull apart, user wins.

**Precedence.** Canonical on structural semantics. Any agent charter that conflicts is wrong. When user's instruction conflicts, say so plainly and ask whether the fundamentals should version forward.

## 2. Core Concepts at a Glance

| # | Entity | What it is | Written as |
|---|---|---|---|
| 1 | Epic | Flexibly scoped slice of user's responsibilities; Objective, Operations, or Bucket type; the unit user prioritizes across daily | Display Name in documents, kebab slug on disk, Type and Statement in EPICS.md (§3.1) |
| 2 | Outcome | A desired result, of any size; Objectives (one-time) or Operations (recurring) | Verb-led Outcome Gist, type-named section, one-sentence statement, fields (§3.2) |
| 3 | Task | Agent-assignable unit of work, defined by the output it produces | Verb-led Task Gist, Task Statement, Agentic Hypothesis, field block (§3.3) |
| 4 | Step | Smallest sequential move toward completing a Task | Table row: imperative line plus Subagent (§3.4) |

**Semantic gradient.** Outcome: what is true when done. Task: what output gets produced. Step: what action gets taken.

**System principles** — full treatment in the craft library; canonical names here for reference: Agentic Decomposition, Confidence-Forward Selection, Two-Hat Standard, Review-Ease, Attention Scheduling, Ambiguity Gate, Continuous Improvement Over Dogma, Interview Bandwidth Craft.

**Reserved level.** Between Epic and Outcome (Milestone / Phase candidates); deliberately not standardized.

## 3. Entity Standards

### 3.1 Epic

Flexibly and inconsistently scoped, numerous, user-defined only — user declares epics by writing them in the DESK; agents never invent, rename, or merge one.

**Three types.** *Objective* epics transform toward an enumerable end. *Operations* epics maintain recurring state. *Bucket* epics are open-ended containers: tasks live directly under the epic with no Outcome layer required, get worked one by one in priority order, and completion is user's felt call, never computed — "Deskflow Reaches MVP" is the founding example. Type lives in the registry; the deskflow steward infers it from user's tree and asks via the ambiguity gate when unclear.

**Three names each.** A kebab slug for the folder, a Display Name for every document user reads, and an **Epic Statement**: one succinct, internally coherent, single sentence, no em-dash splices. Statement lives in EPICS.md, defined once, never shown on the desk.

**Registry.** EPICS.md stack-ranks all epics: `# | Epic | Type | Statement | Folder`, row order is priority. Single writer: the deskflow steward — user declares and reorders epics in the DESK, and the steward maintains the registry and creates epic folders; user never hand-edits it.

### 3.2 Outcome

**Two types.** *Objectives*: one-time. *Operations*: recurring; cadence via tags (§6), fuller mechanics deferred. **No size ceiling.** Bucket epics carry tasks directly and need no Outcomes at all.

**Outcome Gist.** Verb-led, capturing what needs doing and the basic output package. `in {Package}` only when not implied.

- **Good:** `Build Taskflows MVP Spec` · `Evaluate Progress Towards Milestone in Report`
- **Bad:** `Build Taskflows MVP Spec in Doc`

**Fields:** Outcome Statement (required: one sentence, result as-if-true, no em-dash splices, never opens with "The"), Pri (optional, §4), Success Specifics (optional, encouraged; highest authority when present).

### 3.3 Task

Output-defined, never activity-defined. **Archetypes** (Crafting, Process Orchestration, taxonomy open, per craft library) set sizing and Review judgment, identifiable per portion of an outcome.

| # | Field | Required | Standard |
|---|---|---|---|
| 1 | Task Gist | Required | Verb-led, Title Cased, output implied. Never participle adjectives, never "The", never status. |
| 2 | Task Statement | Required | One sentence, output-defined, naming what gets produced and to what bar. |
| 3 | Pri | Optional | Per §4. Beneath Task Statement. |
| 4 | Suggested Agent | Required | Slash name, `me`, or `agent`. `tbd` on the TASKBOARD's Up Next only. |
| 5 | Agentic Hypothesis | Required for non-`me` Tasks | Justification that this scoping suits a razor-focused, reusable specialist. |
| 6 | Expected Input | Optional | What the Task starts from. In multi-task plans, a **handoff contract** with the producing task's Output Essentials — see below. |
| 7 | Output Essentials | Required | Outputs user cares about approving. In multi-task plans, a **handoff contract** with each consuming task's Expected Input — see below. |
| 8 | Procedure Principles | Optional | How the agent should go about it. |
| 9 | Success Specifics | Optional | Concrete checks. |
| 10 | Review | Required | Reviewer agent, `me`, or explicit `none`. Runtime passes recorded as pulse events (§9), never in plan files. |

**Gist examples.** Good: `Clarify Core Vision` · `Refresh Agent Index` · `Clean Both ADO Backlog Trees`. Bad: `Vision Work` · `Approved Core Vision Doc` · `The Backlog Cleanup`.

**Handoff contracts.** When one task's output feeds another, the pair of fields forms a declared contract: the producer's Output Essentials must satisfy the consumer's Expected Input, both written precisely enough that a cold executing agent needs nothing beyond the file. "The findings" is not a contract; "a triaged table of vulnerabilities with severity, location, and one-line evidence per row" is. Precision scales with handoff count and agent coldness — single-agent linear tasks keep lightweight fields; multi-track pipelines (craft library, Pipeline Planning) carry full contracts on every edge.

### 3.4 Step

Table: `# | Step | Subagent`. Imperative, numbered from 1, names its visible manifestation place by style norm. Subagent: `—` / `me` / slash name. Every ratified Task carries Steps. Trailing agent annotations on braindumped step lines (even two per line) are legal at capture and consolidated later.

### 3.5 Agent Designation

Slash names kebab-cased and role-descriptive. `me` = user. `agent` = non-specialist. TASKBOARD Agent vocabulary: `you`, `chat`, `subagent`, slash names, `?`-suffixed proposals, `tbd` in Up Next only.

## 4. Priority Semantics

Bare number, one decimal, 0–3.9, lower more urgent, optional, sequencing-first, mutable. Manual ordering beats Pri sort.

## 5. Taskflow Document Format

Frontmatter: `name`, `version`, `updated`, `epic` (Display Name), optional `status`. **One file, one Outcome.** Title: gist in -ing form + ` — Taskflow Plan`. Task Breakdown table: `# | Task Gist | Suggested Agent | Review | Pri | ID`. Task sections in field order per §3.3. **Plan files are state-free:** progress lives in pulse (§9). **The ID column is the durability anchor:** stable two-letter IDs must persist in plan files so tracking survives desk regeneration. Document voice: label-led, never self-referential.

**Pipeline-shaped plans.** When the decomposition is a pipeline (craft library, Pipeline Planning), the Task Breakdown table gains a `Track` column naming each task's parallel track (or `synthesis` for the merge task), and a one-paragraph DAG sketch precedes the table: tracks named, independence rationale in one line, synthesis close named. Optional for ladders; expected whenever parallel tracks exist.

## 6. DESK Format

User's one working surface: ritual page and workbench. `deskflow/desk/DESK_{yymmdd}-{hhmm}.md`; same-minute stamps append `-01`, `-02`; strict timestamp names only — the engine ignores anything else. At most one DESK is live; **no agent ever edits the live DESK.** Provenance frontmatter: `supersedes`, `snapshot`. Daily archive consolidates stamps into `desk/archive/DESK_{yymmdd}.md`.

**Sections, in order:** For Your Review (experimental), Operations Today, Epics Today (curated), Waiting (on others, with age), One-offs & Inbox Today, Done Today (user moves lines down), Meetings.

**Tree grammar.** 4-space indented, checkboxed; `-`, `*`, and numbered bullets all valid, freely mixed — the engine reads lines, not list styles. Inline content first-class. **Attribute grammar.** `[{tag}]: ` children; `[Agent]:` per bones schema. Originals live in the epic's `raw-prompts.jsonl` (§6a) — a processed desk never carries Raw Prompt content.

**Gist-first lines.** A processed Task line opens with its Task Gist as an inline bolded heading, an em dash, then the Task Statement, with the ID trailing: `- [ ] **Open Epics Today with Operations Trees** — Delivers a desk layout where … [#ot]`. Step lines approved with inline headings follow the same grammar. Epic lines carry no gist and never show the Epic Statement. Done lines strike through the whole line, gist included, with the timestamp tag trailing as always.

**6a. Raw Prompt Gatherings.** Desk bullets and approved statements are many-to-many: one paragraph may decompose into several statements, and one statement may draw on fragments written across different items, sections, or days. The record of what user actually said about an item is therefore not any single bullet but a **gathering** — a steward-assembled stitching of user's original wording, whole sentences or fragments, judged relevant to the statement's definition. Verbatim within each fragment; each fragment carries its source desk as provenance; fragments may repeat across statements. Gatherings live in the owning epic's `raw-prompts.jsonl`, one JSON object per line, append-only, steward-written, machine-read — the self-improver's evidence base, never a display surface.

**Glyphs and tags.** 🔄 recurring · ✓ plan-baseline · 🟧 unplanned · 🟥 not established. Cadence: `[daily]`, `[weekly:Day]`, `[responsively]`; engine-assigned days wear `?`.

**IDs.** Two lowercase letters, letters only, machine-generated, permanent, trailing `[#xx]`. Never on display surfaces, never typed, retyped, or duplicated by user — move lines whole with cut-paste, not copy.

## 7. TASKBOARD Format

Generated radar, never edited, rendered by the engine, opened as a locked preview strip.

**Date format.** `{Dy}.{yymmdd}` — e.g. `Fr.260731`.

**Sections, in order:**

1. **For Your Review:** `# | Epic | Task | Working On | Link`. Working On: two-phrase (focus fragment, comma, what user needs to do). Link: `draft` (linked) or `session`. The ⚡ prefix on the Epic name marks self-improvement proposals.
2. **Epics:** `# | Epic | Task | Working On | ▶ | Agent`. Task is the verb-led gist of the active deliverable. Working On: bare focus fragment, optional comma-phrase for attention. Status: `▶` agent is working, `●` your turn; legend beneath. Agent: `you` / `chat` / `subagent` / slash name. Done Epics excluded.
3. **Waiting:** `# | Item | Since | Who`.
4. **Up Next** (Epics without sessions): `# | Epic | Planned | First Task | First Step | Agent`. Planned: `✓` or blank. First Task names its output place. Agent: slash name with `?`, or `tbd`.
5. **Recent Self-Improvements:** `# | When | What changed | Confidence | Plan | Commit`. Empty until the self-improver runs.
6. **Recently Done:** `# | Epic | Close-Out | When`. Entries drop after two days.

Cells obey the craft library's Voice & Register: no "The" openers, no system nouns, no IDs.

**Snapshots.** Saved to `system/snapshots/TASKBOARD_{yymmdd}-{hhmmss}.md` on every render that changes the board's content. **Cleanup:** within 7 days, all kept; older than 7 days, one per day (the last of that day) survives.

## 8. Folder & Naming Conventions

**System home** `deskflow/system/`: fundamentals, CRAFT-LIBRARY.md, SETTINGS.md (user-owned configuration: epic-sessions, signal-threshold, improvement-mode), deskflow-engine.js and its README, `improvements/` (self-improvement plan files), `snapshots/` (board snapshots), `.proposals/` (temporal planning artifacts, NN.VV-versioned), `.examples/` (illustrative prototypes). **DESK home** `deskflow/desk/` with `archive/`. **Epics** `deskflow/epics/{slug}/`, EPICS.md beside them, both steward-maintained. Each epic folder carries `ledger.md` (the readable tree — for Bucket epics, a Tasks table `# | ID | Task Gist | Task Statement | Status`) and `raw-prompts.jsonl` (Raw Prompt Gatherings, §6a). **Taskflow files** at epic-folder top level, `{NN.VV}-{slug}.md`; **major numbers never reused within an Epic**, archives included. **Archive subfolders** per Epic: `done/`, `cut/`, `active-past/`. **Planning workspaces** `epics/{slug}/planning/{taskflow-slug}/`. **Skills** in `.claude/skills/{name}/SKILL.md`; the Deskflow custom agent in `.github/agents/`. **Stable names** for canon; NN.VV for working artifacts.

**Justfile recipes** (proposal 04.03) wrap the engine: `desk-doctor`, `desk-fresh`, `desk-open`, `desk-watch`, `desk-render`, `desk-archive`, `desk-snapshot-cleanup` — all shell-neutral `node` invocations that paste identically into zsh and PowerShell workspace justfiles.

## 9. Layers, Pulse & the Engine

**Three layers, one engine.** *Plan*: taskflow files and EPICS.md, durable structure, state-free. *Pulse*: per-session `events.md` files, append-only, each session its sole writer, rows `Time | Ref | Event | Note`; times open with `yymmdd`. Event vocabulary: `stage`, `done`, `review-ready`, `blocked`, `note`, `signal` (sentiment-laden exchange tagged for the self-improver). Review passes and approvals are pulse events. *Board*: DESK stamps and TASKBOARD, generated views.

**The engine** (`deskflow-engine.js`, Node built-ins only, spec in its README) is the sole renderer of all views and the sole mechanical propagator: preflight (`doctor`), desk stamping and archiving, checkbox-flip-to-event translation, cadence instantiation, board rendering, snapshots. Judgment belongs to agents; bookkeeping belongs to the engine. User invokes it only through `just desk-*` commands.

## 10. Handoff via Expected Input

A Task is complete when it has produced its Output Essentials, passed its Success Specifics, passed its Review, and produced what its successor's Expected Input calls for when declared. Expectations bind to the declaring Task.

## 11. Orchestration Ground Rules & Change Discipline

**Precedence.** Outcome Statement and Success Specifics govern; Tasks are hypotheses for the Outcome; Steps for the Task.

**Single-writer, no exceptions.** User's live DESK: user. A plan draft: its session. EPICS.md and epic folders: the deskflow steward, fed by user's DESK edits. SETTINGS.md: user. An event file: its session. Generated views: the engine.

**Graceful degradation.** Agents check prerequisites first (`doctor`), never wait beyond fifteen seconds on any external command, and treat background CLI sessions as an upgrade, never a requirement — /deskflow delivers full value in single-session mode.

**Commit cadence.** Every write is committed and pushed immediately — no significance threshold, no batching, no waiting to be asked. The full contract — approval-moment commits, scoped adds, message format, push failure protocol — lives in the craft library's Persistence Contract section and binds every session.

**Version forward.** Canonical files bump frontmatter versions. Working artifacts take a new VV. Agents read latest at task start; mid-flight updates apply from the next Task boundary.

**Experimental markers.** On trial: For Your Review on the DESK, the `Now:` watch-pane prefix, ledger-based Raw Prompt gatherings, grace continuation across day rollover, and archived-session revival.
