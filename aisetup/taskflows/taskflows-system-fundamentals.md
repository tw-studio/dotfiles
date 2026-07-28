---
name: taskflows-system-fundamentals.md
version: 00.06
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
| Focus Area | Flexibly scoped slice of user's responsibilities; the unit user prioritizes across daily | Kebab-cased folder name, user-defined | Via index |
| Outcome | A desired result; Objectives type (one-time) or Operations type (recurring) | Verb-led Outcome Gist, type-named section, one-sentence statement, fields (§3.2) | Optional |
| Task | Agent-assignable unit of work, defined by the output it produces | Task Gist, Task Statement, Agentic Hypothesis, field block (§3.3) | Optional |
| Step | Smallest sequential move toward completing a Task | Table row: imperative line plus Subagent (§3.4) | Position only |

**Semantic gradient.** An Outcome says what is true when it is done. A Task says what output gets produced. A Step says what action gets taken. Keep each level in its lane: results at the top, outputs in the middle, actions at the bottom.

**Agentic decomposition.** The system's core hypothesis: successful agentic execution of a big Outcome comes from breaking it into right-sized interim deliverables, each one something a specialist agent can be tuned to, razor-focused on, and trusted to deliver at high quality with high confidence — ideally scoped with enough generality that the specialist is reusable across taskflows. A taskflow is the claim that the right sequence of right-sized Tasks for right-sized specialists has been found; each Task's Agentic Hypothesis (§3.3) states why its scoping earns a place in that claim.

**Reserved level.** A level between Focus Area and Outcome (working names: Objective / Vision) is reserved but deliberately not standardized. Agents must not invent standards for it; user will define it from usage evidence.

## 3. Entity Standards

### 3.1 Focus Area

Flexibly scoped, numerous by design — user's current set runs around twenty, many being sub-areas of one large responsibility (e.g. `service-keep-lights-on`, `service-onboarding`, `service-wiki`, `manager-1-1s`). Scoping criteria are deliberately imprecise and inconsistent: the enumeration exists to match user's mental model for making prioritized daily progress, nothing more. Only rarely is a focus area just a product or service name itself, though it can be, especially before user has decomposed it.

**User-defined, always.** User creates and names focus areas — directly, or by instructing an agent with the exact name. Agents never invent, rename, merge, or infer focus areas, and never need to understand the scoping criteria.

### 3.2 Outcome

**Two types.** *Objectives* Outcomes are one-time: achieved once, then done. *Operations* Outcomes are recurring: maintained true period after period via repeating work. Recurrence mechanics (periods, resets, period status) are deferred until the first recurring taskflow exists — define nothing about them until then.

**Outcome Gist.** Canonical compact form of an Outcome, used wherever the Outcome is referenced — and, in -ing form, as its taskflow file's title (§5). Starts with a verb, and captures both the gist of what needs to be done and the basic package the output is expected in. The `in {Output Package Term}` pattern often carries the package — but only when the package isn't already implied by the gist. Package terms name the concept of what gets directly evaluated, never the file format.

- **Good:** `Build Taskflows MVP Spec`
- **Good:** `Evaluate Progress Towards Milestone in Report`
- **Good:** `Articulate Next Real Outcome in Backlog`
- **Bad:** `Build Taskflows MVP Spec in Doc` — the spec is already the package; `in Doc` adds nothing.

**Expression in a taskflow file.** One taskflow file carries exactly one Outcome (§5). Its gist lives in the file title; its section is headed by its type name — `Objective` or `Operational Outcome` — with the Outcome Statement directly beneath as plain prose.

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

**Defining principle.** A Task is what an agent gets assigned to, and it is defined by the output it produces — never by the activity performed to get there. When writing or evaluating a Task, the first questions are always: what does it consume, and what must exist when it is done? Task scoping is where agentic decomposition (§2) gets applied — and each Task's Agentic Hypothesis is where that application gets justified.

| # | Field | Required | Standard |
|---|---|---|---|
| 1 | Task Gist | Required | Title Cased, roughly one to six words, fully self-explanatory. Reading it alone must convey the full scope of the Task — no further reading, no guessing. Never encode status in a gist: approval state lives in the Approval field, and repeating it gist after gist ruins the scan. |
| 2 | Task Statement | Required | One full, readable sentence stating exactly what the Task is — output-defined, naming what gets produced and to what bar. A miniature Outcome Statement at Task scope. |
| 3 | Pri | Optional | Per §4. Renders directly beneath Task Statement. |
| 4 | Suggested Agent | Required | Slash-named specialist (e.g. `/product-core-vision-clarifier`), `me` (user), or `agent` (competent non-specialist; no special charter needed). Never blank — envisioning the needed agent is part of planning a Task. |
| 5 | Agentic Hypothesis | Required for `/specialist` and `agent` Tasks; omitted for `me` Tasks | Concise justification for why this scoping, at this stage of outcome delivery, is an interim deliverable a specialist agent can be razor-focused on and deliver at high quality with high confidence — reuse across taskflows in view. Manifests §2's agentic decomposition principle for this specific Task; pairs with Suggested Agent as its justification. |
| 6 | Expected Input | Optional | What the Task starts from: files, a predecessor's output, a braindump user will attach. |
| 7 | Output Essentials | Required | Outputs that matter — the ones user cares about approving. This field is the Task's defining core. |
| 8 | Procedure Principles | Optional | How the agent should go about it, when that matters: interview mechanics, ordering rules, style constraints. |
| 9 | Success Specifics | Optional | Concrete checks the output must pass before the Task can be called done. |
| 10 | Approval | Optional — experimental | If set at planning time: `Required` (user will review the output before successors consume it) or `Trusted` (proceed without user). At runtime, `Required` flips to `Approved` on sign-off. When absent, no orchestrator obligation is defined yet; treat as trusted, with judgment. Renders after Steps, last in the section. Field earns real semantics from first-run evidence; verdict then. |

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

**Agentic Hypothesis examples.**

- **Good:** "Detail specification is high-volume, format-driven elaboration within an already-approved structure — exactly the razor-focused, low-ambiguity work a specialist excels at once format standards are pinned."
- **Bad:** "An agent can do this." — asserts capability without justifying the scoping, the stage fit, or the specialization.

### 3.4 Step

Steps render as a table: `# | Step | Subagent`. Step is a short imperative line stating one concrete action, numbered from 1, strictly sequenced within its Task. Subagent column values: `—` (em dash) when the Task's Suggested Agent performs the step itself; `me` when user does; a slash-named subagent when the step is delegated. No Pri — position is the ordering. Every Task in a ratified taskflow plan carries Steps; absent Steps means planning is still in progress. Steps are the current best decomposition, freely revisable during execution (§8).

- **Good:** `Ingest the vision braindump and workspace context in full before asking anything.`
- **Bad:** `Make progress on the vision doc.` — no single concrete action; can never be checked off with confidence.

### 3.5 Agent Designation

Slash names are kebab-cased and role-descriptive: `/product-architecture-specifier`, `/agent-recommender`. `me` designates user. `agent` designates non-specialist agentic work where any competent general instance suffices. These three forms are the complete set of valid values for Suggested Agent; the Subagent column additionally uses `—` for the Task's own agent.

## 4. Priority Semantics

Pri is a bare number — no letter attached — always written with one decimal place: `1.0`, not `1`; `2.5` is valid. Range 0 to 3.9, lower means more urgent. Optional at every level that carries it. Priority is first and foremost a sequencing mechanism — importance-driven or practicality-driven — and values are expected to change over time as urgency shifts. Default sort where sorting applies; explicit manual ordering, when present, wins over Pri sort.

## 5. Taskflow Document Format

A taskflow is a markdown file. Frontmatter carries `name` (the filename without any `NN.VV` prefix), `version`, `updated`, `area` (the focus area), and optionally `status` for operational notes an orchestrator needs (provisional, superseded-by, and the like).

**One file, one Outcome.** A taskflow file is tied to exactly one Outcome — a deliberate constraint at this time. Work spanning several Outcomes becomes a sequence of taskflow files, one per Outcome.

**Title standard.** The title is the Outcome Gist (§3.2) rendered in -ing form, followed by the ` — Taskflow Plan` suffix. Comprehensible in isolation — reading the title alone, out of context, orients completely.

- **Good:** `Building Taskflows MVP Spec — Taskflow Plan`
- **Good:** `Evaluating Progress Towards Milestone in Report — Taskflow Plan`
- **Bad:** `Spec Work — Taskflow Plan` — orients nobody.

**Document voice.** Direct, technical, label-led: bold field labels first, content after. Nothing discursive — a taskflow file never talks about itself, never editorializes, never fills space. If a line isn't orienting the reader or specifying the work, it doesn't belong.

**Body structure:**

```
# {Outcome Gist, -ing Form} — Taskflow Plan

## Objective                     (or: ## Operational Outcome)

{Outcome Statement as plain prose.}

**Pri:** ...

**Success Specifics:**
- ...

## Task Breakdown

| # | Task Gist | Suggested Agent | Approval | Pri |

## Task 1 — {Task Gist}

**Task Statement:** ...
**Pri:** ...
**Suggested Agent:** ...
**Agentic Hypothesis:** ...
**Expected Input:** ...
**Output Essentials:**
- ...
**Procedure Principles:** (when used)
**Success Specifics:** (when used)

**Steps:**
| # | Step | Subagent |

**Approval:** ...
```

**Why hybrid.** Long-form fields (Output Essentials, Procedure Principles) cannot live in table cells without destroying readability, so each Task gets its own section; the Task Breakdown table exists purely for the scan. Table rows and section headings must never disagree — the section is authoritative, the table is its index.

**Numbering.** In-document numbering starts at 1: task indices are bare numbers (`1, 2, 3`) in the Task Breakdown table and `Task N` in section headings; steps and all numbered lists start at 1. Filesystem `NN.VV` numbering stays 00-based per §6 — the two conventions coexist deliberately.

**Worked example:** `taskflows/system/examples/00.02-building-taskflows-mvp-spec.md`. When it and this file disagree, this file wins and the example gets fixed.

## 6. Folder & Naming Conventions

**System home.** `taskflows/system/` holds the system's canonical artifacts: this file, `examples/`, proposals for system design still in flight, and later the agent index and status log.

**Focus areas.** `taskflows/focus-areas/` holds one subfolder per focus area (§3.1), kebab-named by user. Everything belonging to a focus area lives inside its folder, so a single `git add` scopes cleanly to one area.

**Taskflow files.** Live at the top level of their focus area's folder: `focus-areas/{focus-area}/{NN.VV}-{slug}.md`, slug drawn from the Outcome Gist's -ing form. **Major numbers are never reused within a focus area:** when assigning `NN`, scan the folder *including* its archive subfolders, and take the first major number never used anywhere in that focus area.

**Archive subfolders.** Optional, standard names, per focus area: `done/` for completed taskflows, `cut/` for abandoned ones, `active-past/` for superseded versions of still-active taskflows that user no longer wants at top level. All files sharing a major number move to `done/` or `cut/` as a group — every VV together — and stay at top level until the whole group can move.

**Focus-area index.** `taskflows/focus-areas/FOCUS-AREAS.md` stack-ranks all focus areas in priority order. Deliberately minimal until usage teaches more. Written by user (or a future sync job — never both; §8).

**Daily working files.** User's primary work surface pending the Taskflows app: `focus-areas-{yymmdd}-{hhmm}.md` files in `taskflows/focus-areas/daily/`. Two rules are canonical now; the rest of the lifecycle is proposed, not canon (see `system/00.00-daily-flow-proposal.md`): at most one live daily file exists at any time, and no agent ever edits the live daily file (§8).

**Planning workspaces.** `focus-areas/{focus-area}/planning/{taskflow-slug}/` holds each taskflow's planning workspace — proposals, drafts, reviews, chat history — used by /taskflow-planner.

**Reserved:** `taskflows/focus-areas/FOCUS-AREAS-TREES.md` — a full rollup view of all focus areas' Outcomes, Tasks, and Steps. When built, it is a *generated* file: one generation job is its only writer, no agent or human edits it, and it is rebuilt from the taskflow files rather than maintained. Deferred until FOCUS-AREAS.md and the daily file prove insufficient.

**Product efforts.** `product-flows/{product-version}/` (e.g. `taskflows-mvp/`), containing `sprints/`, containing 00-indexed `sprint-{NN}-{theme-slug}/` folders. Within each sprint: `agentspaces/`, containing `{agent-name}-{NN}/` per agent run, each with at least `proposals/`, `chat-history/`, `logs/`, `drafts/`, `finals/`. Orchestrators get agentspaces too and log there frequently. Sibling to `agentspaces/`: `handoffs/`, receiving copies of everything that lands in any `finals/`, named `{NN.VV}-{description}-{type}.{ext}` with numbering relative to that `handoffs/` folder.

**NN.VV numbering.** `NN` is the first major number not yet taken in that folder (for taskflow files: never used anywhere in the focus area, archives included); `VV` is the monotonically increasing revision of that file. Both always start at `00`.

**Stable names for canonical references.** Files agents must reliably route to — this file foremost — keep a fixed filename; the version lives in frontmatter and git holds history. Working artifacts (plans, drafts, handoffs) carry `NN.VV` in the filename, mirrored by `version` in frontmatter.

## 7. Handoff via Expected Input

A Task is complete when it has produced its Output Essentials, passed its Success Specifics, **and** produced what its successor's Expected Input calls for, when the successor declares one. Expectations bind to the Task that declares them and resolve at runtime against whichever Task actually precedes it — so reordering Tasks never breaks a declaration. Handoff artifacts publish to the effort's `handoffs/` folder under §6 naming.

## 8. Orchestration Ground Rules

**Precedence.** Outcome Statement and its Success Specifics govern. Tasks are the current best hypothesis for achieving the Outcome; Steps are the current best hypothesis for completing their Task. When execution reveals a conflict, the higher level wins and the lower level gets revised — an orchestrator optimizes for the Outcome, never for step-completion.

**Single-writer rule.** Every file in the system has exactly one writer class, and cross-writing is forbidden — conflict prevention comes from this structure, never from merge cleverness. User's live daily file: user only, no agent ever. A taskflow draft: its planner session. A generated view (FOCUS-AREAS-TREES.md when built): its one generation job. FOCUS-AREAS.md: user, until a sync job takes over — never both concurrently. An agent's logs and agentspace: that agent. The one sanctioned multi-writer file is the status log, and only because it is append-only.

**Status log.** One append-only status file per workspace in the current single-machine setup. Any agent appends rows; no agent edits or deletes prior rows. Columns: `Time | Agent | Ref | Event | Note` — where Ref points at the Outcome/Task/Step concerned and Note may carry a link. Latest state is read from the bottom up.

**Commit cadence.** Agents commit and push whenever they write meaningful artifacts — logs, drafts, handoffs, finals — so a crashed machine or dead chat session can always be resumed from the trail by a fresh instance.

## 9. Change Discipline

**Version forward.** Meaning never changes silently in place. This file: bump frontmatter `version`, keep the filename stable, let git carry history. Working artifacts: new `VV`.

**Mid-flight updates.** Agents read the latest fundamentals at task start. An update landing mid-taskflow applies from the next Task boundary onward — never retroactively to work already approved.

**Experimental markers.** Currently on trial: the Approval field (§3.3). It gets an explicit verdict — kept, revised, or dropped — after the first real taskflow run completes.
