---
name: taskflows-system-fundamentals.md
version: 00.02
updated: 2026-07-27
---

# Taskflows System Fundamentals

Canonical reference for the Taskflows system: its entities, statement standards, document formats, and conventions. Every agent that plans, executes, or reports on taskflows reads this file as runtime knowledge, and user edits it as the single authority on Taskflows semantics.

## 1. Purpose & Readers

**What this file governs.** Concepts and standards of the Taskflows *system* — data model, statement formats, taskflow document format, folder and naming conventions, and orchestration ground rules. It does not specify the Taskflows *app* (that product spec is pipeline output living under `product-flows/`), and it is not any agent's charter (charters defer to this file).

**Two readers, one contract.** A cold agent instance must be able to produce or execute a conforming taskflow from this file alone. User must be able to scan it, drill into any standard, and edit it confidently. When the two pull apart, user wins.

**Precedence of this file.** Canonical on Taskflows semantics. Any agent charter, plan, or artifact that conflicts with it is wrong, and the fix happens there — unless user decides the fundamentals themselves should change, in which case this file versions forward (§9).

## 2. Core Concepts at a Glance

| Entity | What it is | Written as | Pri |
|---|---|---|---|
| Area | Topmost grouping; the title user navigates by | Short name | — |
| Outcome | A desired result; Objectives type (one-time) or Operations type (recurring) | Heading as Detailed Gist, one-sentence statement, fields (§3.2) | Optional |
| Task | Agent-assignable unit of work, defined by the output it produces | Task Gist, one-sentence Task Statement, field block (§3.3) | Optional |
| Step | Smallest sequential move toward completing a Task | Short imperative line, numbered from 1 | Position only |

**Semantic gradient.** An Outcome says what is true when it is done. A Task says what output gets produced. A Step says what action gets taken. Keep each level in its lane: results at the top, outputs in the middle, actions at the bottom.

**Reserved level.** A level between Area and Outcome (working names: Objective / Vision) is reserved but deliberately not standardized. Agents must not invent standards for it; user will define it from usage evidence.

## 3. Entity Standards

### 3.1 Area

Short name, nothing more for now — e.g. `Taskflows`. Areas can be timebound projects or ongoing areas of responsibility; the system imposes no distinction yet.

### 3.2 Outcome

**Two types.** *Objectives* Outcomes are one-time: achieved once, then done. *Operations* Outcomes are recurring: maintained true period after period via repeating work. Recurrence mechanics (periods, resets, period status) are deferred until the first recurring taskflow exists — define nothing about them until then.

**Heading as Detailed Gist.** An Outcome's heading *is* its gist, in detailed form: Title Cased, roughly six to eight words, up to ten when needed, and fully comprehensible in isolation — reading the heading alone, out of context, tells you what the Outcome is about. An inline `[Outcome]` marker sits at the heading's end (format on trial, §9). No separate gist field exists.

- **Good:** `Spec Specialists Built And Taskflows MVP Spec Delivered`
- **Bad:** `Spec Pipeline Delivered` — too short to stand on its own; forces reading further to learn which pipeline, for what.

| Field | Required | Standard |
|---|---|---|
| Outcome Statement | Required | One full, readable sentence stating the desired result as if already true. |
| Pri | Optional | Per §4. |
| Success Specifics | Optional, encouraged | Concrete checks that must all pass before the Outcome is called achieved. When present, they are the highest authority in the taskflow (§8). |

**Outcome Statement examples.**

- **Good:** "Taskflows MVP has an approved product specification produced end to end by the spec specialists, each commissioned through /agent-creator and live-tested by producing its real deliverable."
- **Bad:** "Build the pipeline agents." — imperative action, not a result; that phrasing belongs below the Outcome level.
- **Bad:** "Pipeline agents." — not a sentence; states nothing about the desired world.

### 3.3 Task

**Defining principle.** A Task is what an agent gets assigned to, and it is defined by the output it produces — never by the activity performed to get there. When writing or evaluating a Task, the first questions are always: what does it consume, and what must exist when it is done?

| # | Field | Required | Standard |
|---|---|---|---|
| 1 | Task Gist | Required | Title Cased, roughly one to six words, fully self-explanatory. Reading it alone must convey the full scope of the Task — no further reading, no guessing. Never encode status in a gist: approval state lives in the Approval field, and repeating it gist after gist ruins the scan. |
| 2 | Task Statement | Required | One full, readable sentence stating exactly what the Task is — output-defined, naming what gets produced and to what bar. A miniature Outcome Statement at Task scope. |
| 3 | Suggested Agent | Required | Slash-named specialist (e.g. `/product-core-vision-clarifier`), `me` (user), or `agent` (competent non-specialist; no special charter needed). Never blank — envisioning the needed agent is part of planning a Task. |
| 4 | Expected Input | Optional | What the Task starts from: files, a predecessor's output, a braindump user will attach. |
| 5 | Output Essentials | Required | Outputs that matter — the ones user cares about approving. This field is the Task's defining core. |
| 6 | Procedure Principles | Optional | How the agent should go about it, when that matters: interview mechanics, ordering rules, style constraints. |
| 7 | Success Specifics | Optional | Concrete checks the output must pass before the Task can be called done. |
| 8 | Pri | Optional | Per §4. |
| 9 | Approval | Optional — experimental | If set at planning time: `Required` (user will review the output before successors consume it) or `Trusted` (proceed without user). At runtime, `Required` flips to `Approved` on sign-off. When absent, no orchestrator obligation is defined yet; treat as trusted, with judgment. Field earns real semantics from first-run evidence; verdict then. |

**On unbuilt specialists.** A Suggested Agent that does not exist yet is a normal, expected state — it is discovered by checking the fleet, never marked in the field. At execution time the sourcing order is: existing fleet → /agent-recommender candidates → commission the build via /agent-creator under the envisioned name. The envisioned name is a proposal; a commission-time rename is allowed and does not block upstream documents.

**Task Gist examples.**

- **Good:** `Core Vision Doc` — names the output; scope is instantly clear.
- **Good:** `Refreshed Agent Index` — one read, full gist.
- **Bad:** `Vision Work` — could mean nearly anything; forces further reading.
- **Bad:** `Approved Core Vision Doc` — smuggles approval status into the gist; that is the Approval field's job.
- **Bad:** `Interview User And Draft The Vision Doc` — activity-phrased and overlong; the output, not the activity, defines a Task.

**Task Statement examples.**

- **Good:** "Delivers a user-approved core vision doc for Taskflows MVP capturing the elevator pitch, complete job enumeration, tech stack decision, and style gists."
- **Bad:** "Interview user about the product vision." — activity, not output; says nothing about what exists when the Task is done.

### 3.4 Step

Short imperative line stating one concrete action, numbered from 1, strictly sequenced within its Task. No Pri — position is the ordering. When a step's actor differs from the Task's Suggested Agent, append a bracketed actor tag — e.g. `6. Approve the doc plan. [me]`. Steps are the current best decomposition, freely revisable during execution (§8).

- **Good:** `1. Ingest the vision braindump and workspace context in full before asking anything.`
- **Bad:** `Make progress on the vision doc.` — no single concrete action; can never be checked off with confidence.

### 3.5 Agent Designation

Slash names are kebab-cased and role-descriptive: `/product-architecture-specifier`, `/agent-recommender`. `me` designates user. `agent` designates non-specialist agentic work where any competent general instance suffices. These three forms are the complete set of valid Suggested Agent values.

## 4. Priority Semantics

Pri is a bare number — no letter attached — always written with one decimal place: `1.0`, not `1`; `2.5` is valid. Range 0 to 3.9, lower means more urgent. Optional at every level that carries it. Priority is first and foremost a sequencing mechanism — importance-driven or practicality-driven — and values are expected to change over time as urgency shifts. Default sort where sorting applies; explicit manual ordering, when present, wins over Pri sort.

## 5. Taskflow Document Format

A taskflow is a markdown file. Frontmatter carries `name` (the filename without any `NN.VV` prefix), `version`, `updated`, and `area`.

**Title standard.** A taskflow's title is held to the same detailed-gist standard as Outcome headings (§3.2): Title Cased, comprehensible in isolation. When a file carries a single Outcome, title and Outcome heading may simply match.

**Fixed intro structure.** Body opens with exactly two subsections before the first Outcome — never freeform prose:

- **Purpose** — two to four sentences: what this taskflow delivers and why it exists now. A closing operational note (supersession, provisional status) is permitted when an orchestrator needs it.
- **Outcome Summary** — table `# | Outcome | Pri`, the scan index for the file. Always present, even with a single Outcome, so every taskflow file opens identically.

**Document voice.** Direct, technical, label-led: bold field labels first, content after. Nothing discursive — a taskflow file never talks about itself, never editorializes, never fills space. If a line isn't orienting the reader or specifying the work, it doesn't belong.

**Body structure:**

```
# {Taskflow Title}

## Purpose

{Two to four sentences.}

## Outcome Summary

| # | Outcome | Pri |

## {Detailed Gist} [Outcome]

**Outcome Statement:** ...
**Pri:** ...
**Success Specifics:**
- ...

### Task Summary

| # | Task Gist | Suggested Agent | Pri | Approval |

### Task 1 — {Task Gist}

**Task Statement:** ...
**Suggested Agent:** ...
**Expected Input:** ...
**Output Essentials:**
- ...
**Procedure Principles:** (when used)
**Success Specifics:** (when used)
**Pri:** / **Approval:** (when used)

**Steps:**
1. ...
2. ...
```

**One or many Outcomes.** A taskflow file carries one or more Outcomes in sequence, each repeating the full structure above. Multiple Outcomes is the norm at sprint scale — a sprint taskflow is defined as a sequence of Outcomes — and single-Outcome files are equally legitimate.

**Why hybrid.** Long-form fields (Output Essentials, Procedure Principles) cannot live in table cells without destroying readability, so each Task gets a block; the summary tables exist purely for the scan. Table rows and block headings must never disagree — the block is authoritative, the table is its index.

**Numbering.** In-document numbering starts at 1: outcome and task indices are bare numbers (`1, 2, 3`) in summary tables, `Task N` in block headings; steps and all numbered lists start at 1. Filesystem `NN.VV` numbering stays 00-based per §6 — the two conventions coexist deliberately.

Steps may be omitted for Tasks not yet decomposed — absent Steps means "not yet planned," and that is a legitimate published state.

**Worked example:** `taskflows/examples/00.00-taskflows-mvp-spec-taskflow.md`. When it and this file disagree, this file wins and the example gets fixed.

## 6. Folder & Naming Conventions

**System home.** `taskflows/` at workspace top level holds this file, `examples/`, and later system artifacts (agent index, status log).

**Product efforts.** `product-flows/{product-version}/` (e.g. `taskflows-mvp/`), containing `sprints/`, containing 00-indexed `sprint-{NN}-{theme-slug}/` folders. Within each sprint: `agentspaces/`, containing `{agent-name}-{NN}/` per agent run (NN counts runs of that agent within the sprint), each with at least `proposals/`, `chat-history/`, `logs/`, `drafts/`, `finals/`. Orchestrators get agentspaces too and log there frequently. Sibling to `agentspaces/`: `handoffs/`, receiving copies of everything that lands in any `finals/`, named `{NN.VV}-{description}-{type}.{ext}` where numbering is relative to that `handoffs/` folder.

**NN.VV numbering.** `NN` is the first major number not yet taken in that folder; `VV` is the monotonically increasing revision of that file. Both always start at `00`.

**Stable names for canonical references.** Files agents must reliably route to — this file foremost — keep a fixed filename; the version lives in frontmatter and git holds history. Working artifacts (plans, drafts, handoffs) carry `NN.VV` in the filename, mirrored by `version` in frontmatter.

## 7. Handoff via Expected Input

A Task is complete when it has produced its Output Essentials, passed its Success Specifics, **and** produced what its successor's Expected Input calls for, when the successor declares one. Expectations bind to the Task that declares them and resolve at runtime against whichever Task actually precedes it — so reordering Tasks never breaks a declaration. Handoff artifacts publish to the effort's `handoffs/` folder under §6 naming.

## 8. Orchestration Ground Rules

**Precedence.** Outcome Statement and its Success Specifics govern. Tasks are the current best hypothesis for achieving the Outcome; Steps are the current best hypothesis for completing their Task. When execution reveals a conflict, the higher level wins and the lower level gets revised — an orchestrator optimizes for the Outcome, never for step-completion.

**Status log.** One append-only status file per workspace in the current single-machine setup. Any agent appends rows; no agent edits or deletes prior rows. Columns: `Time | Agent | Ref | Event | Note` — where Ref points at the Outcome/Task/Step concerned and Note may carry a link (to an output awaiting review, for instance). Latest state is read from the bottom up.

**Commit cadence.** Agents commit and push whenever they write meaningful artifacts — logs, drafts, handoffs, finals — so a crashed machine or dead chat session can always be resumed from the trail by a fresh instance.

## 9. Change Discipline

**Version forward.** Meaning never changes silently in place. This file: bump frontmatter `version`, keep the filename stable, let git carry history. Working artifacts: new `VV`.

**Mid-flight updates.** Agents read the latest fundamentals at task start. An update landing mid-taskflow applies from the next Task boundary onward — never retroactively to work already approved.

**Experimental markers.** Currently on trial: the Approval field (§3.3) and the inline `[Outcome]` heading marker (§3.2). Each gets an explicit verdict — kept, revised, or dropped — after the first real taskflow run completes.
