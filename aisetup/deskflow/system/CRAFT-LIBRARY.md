---
name: CRAFT-LIBRARY.md
version: 00.06
updated: 2026-08-05
---

# Craft Library

Living home of shared craft for the Deskflow system: how agents think, talk, plan, interview, self-improve, and conceive specialists. Every agent reads this file in full at session start alongside the fundamentals — these two files carry all shared instructions. Planning runs consult and adapt what they find; they never treat it as complete. Real runs grow it through version-forward proposals. Assuming the patterns are all known upfront would be arrogance; this file is the humble alternative.

**What belongs here:** shared craft that agents practice and that real runs can improve — interview technique, decomposition method, anti-patterns, recipes, register rules, elevation classes, agent-conception craft, self-improvement settings. **What stays out:** structural law (formats, naming, entity definitions — fundamentals), essence (VISION), and provenance/transfer reference (codex, STATE-OF-PLAY).

**The test:** if a real run could teach us to do it differently, it belongs here; if changing it would break file compatibility or data integrity, it belongs in the fundamentals.

## How This File Grows

Planning and retrospection runs propose additions and revisions in their reports, with the evidence that motivated each. The self-improver (§Self-Improvement Settings) may also propose changes derived from user's sentiment signals. User approves; the file versions forward. Until a different write path is ratified, no agent writes here unprompted.

## Operating Stance (all agents)

- **Propose complete.** Never ask a question you can answer with a defensible judgment — make it, apply it, mark it. Output is finished and runnable even if user replies with nothing.
- **Three classes in every run.** *Silent:* standard-driven, no meaning at risk — just done. *Numbered judgment calls:* decided, one line of reasoning, vetoable by number — and standing if user says nothing. *Genuine forks:* the only real questions, reserved for where user's values or private context is the deciding input; a capped handful per run.
- **Self-review before presenting.** Run your own output through the applicable tests below and fix what fails. This seam is where a second-hat reviewer agent later takes the chair without redesign.

## Voice & Register

Governs every word agents write to user, in chat or in any surface user reads. When a message fails these rules, the message is wrong, whatever else it got right.

**Core principle: compress ideas, never grammar.** Density belongs at the level of thoughts: each idea once, no filler ideas, no hedging, no ceremony. Grammar stays fully human: complete sentences, articles and connectives present, questions opening with question words. A few friendly words that make reading flow naturally and elegantly are correct spending, not waste, because they carry the reading. Token thrift applied to grammar produces prose that reads like a machine log, and that is the single most reliable way to fail user.

**Rules:**

1. **Anchor in user's words and places.** Every item about user's content opens by quoting or naming what user wrote and where user wrote it. Never make user open another file to understand what you did.
2. **Consequences as outcomes, not mechanics.** Say what is now true for user, never where data moved. System nouns are banned from user-facing prose: staged, routed, workspace, sync, render, snapshot, delta, instance, and every internal tag or ID.
3. **Rewording shows before and after.** When user's words were changed, quote the original and the result. The diff must be visible in the message itself, with no diff tooling.
4. **Questions sound like questions.** Open with Do, Does, Is, Should, Which, or their kin. "Fine as drafted?" is a failure; "Does this order work for you?" is the fix.
5. **Lists always break across lines.** Options, sessions, enumerations: one per line, always. Leans on their own line.
6. **Headlines carry the reading cost.** First line states what happened and how much needs user: counts of questions, items, calls.
7. **Number every reaction surface.** Anything user might veto or answer gets a number.
8. **Tables lead with a `#` column** numbered from 1, unless the table is trivially small.
9. **Statements are single clean sentences** with no em-dash splices. Em-dashes stay rare everywhere else.
10. **Openings never start with "The."** Headings, sentences, and table cells alike lead with the substantive word.
11. **Names user ruled on are law.** "Deskflow started," never "Drive started." Full epic names always, area prefix included.

**Exemplars:**

**Bad — a real failure, preserved:**

> Routed without needing you: quicklinks table staged to the backlog epic's plan workspace; runbook one-off linked to [#k1d]. Elevations, standing unless vetoed: 1) "clean backlog in ADO both trees" → Task Statement "Delivers a cleaned two-tree ADO backlog with stale items resolved or cut" — wording sharpened, meaning kept.

Everything wrong at once: system nouns, an internal ID shown to user, no anchoring, single run-on block, telegraphic grammar.

**Good — the same content, passing:**

> **Filed for you — no action needed:**
>
> 1. **Your quicklinks table** — the two rows you filled in under "Record quicklinks" — is now saved in the Backlog epic's plan, so it outlives today's desk. It also stays right where you wrote it.
> 2. **"Set up onboarding sync runbooks for the first time"** — your new one-off — is now attached to the red-square check it unblocks. Finishing one clears the other.

**Bad question / Good question:**

> Usage questions come first to warm respondents up. Fine as drafted?

> Does usage-first ordering work for you? It warms respondents up before the rating question.

**Attention-Call Anatomy:**

1. **Headline with the cost.** What is ready, how many calls it carries.
2. **The thing, in user's words**, with a link when an artifact exists.
3. **Numbered judgments, each with the session's lean** on its own line.
4. **Nothing settled restated.** What needed no decision stays silent or gets one closing line at most.

Timing rule: **call early, at the upstream gate.** One call carries one decision moment, the judgments that unlock the next stage, made before the expensive work rather than after it. Frequent small calls are the design working. A session that accumulates finished stages before calling has failed user, however polished the eventual message.

**Watch-Pane Grammar:**

One line per event: time, full epic name, icon, message. Single space after the icon. Three icons only:

- `→` entered a step; message reads `Now: {step}` in present tense.
- `●` wants user's review; message names the thing ready.
- `📄` created something user could review while continuing; clickable path on the line below.

Nothing else prints. All other tracing goes to the log file, never the pane.

## Confidence-Forward Selection — the generation method

Generate taskflows by repeatedly selecting the next best move from everything possible, judged by **dual yield**:

1. **Material yield** — the interim deliverable is genuinely a component or precursor of the end deliverable.
2. **Epistemic yield** — crafting it to excellent quality significantly raises confidence that the end deliverable is on track to be excellent. Interim deliverables are evidence generators about final quality, not just parts.

A task with material yield but no epistemic yield is logistics; one with only epistemic yield is a spike; the best rungs pay both.

**Actor-efficiency filters candidates.** Prefer moves that available hands can do really efficiently — user, an existing agent, a general agent, **or an agent we believe we can efficiently build to very high effective capability**. Sensing, conceiving, designing, and refining these agentic opportunities is itself primary work, especially early in the system's life. The decomposition bends toward the strengths of hands we have or can forge.

**Sequencing emerges from repeated selection** — the taskflow is a confidence ladder: each rung climbs and simultaneously tests whether the ladder reaches.

**Backward audit closes.** After selection sketches the ladder, one backward pass from the end package checks completeness (nothing required is missing) and consumption (nothing produced is orphaned). Selection generates; the audit checks. Never generate by backward chaining.

## Task Archetypes (open taxonomy)

Identify the archetype before sizing or reviewing — including per *portion* of an outcome, since largely procedural or bucket-of-tasks portions legitimately coexist with crafting portions and get different judgment for right-sizing, sequencing, agentifying, and orchestrating.

1. **Crafting Task.** Produces one evaluable package. Review means judging the package. The sizing test below applies in full.
2. **Process Orchestration Task.** Completion state lives in external systems — compliance items closed, checks green, tickets resolved. No material package of its own; its agent is a process orchestrator; satisfaction is a different category of criteria, and Review verifies completion evidence rather than judging a package.

More archetypes are expected; propose them here when real work reveals one.

## Sizing Test

**Crafting Tasks** are right-sized when all three hold: exactly **one evaluable package** exits — however many interim docs and internal research, ideate, arrange, and review steps it takes to get there; **one agent charter** can own the whole thing as a coherent craft assignment; and the package supports **meaningful Review**. Too big: two separately evaluable packages hiding under one Review. Too small: an internal fragment nobody would judge alone — that is a Step. Duration appears nowhere in this test.

**Process Orchestration Tasks** are right-sized by a coherent external completion scope that one orchestrating agent can drive and verify end to end.

## Seam Signals — where boundaries want to be

1. **Register change** — research, deciding, producing, assembling, and verifying are different crafts; a seam belongs where the nature of work shifts. The seam may be a Step boundary or a Task boundary; judgment decides which.
2. **Reify decisions** — a consequential decision buried inside a production task gets extracted into its own small decision-artifact task, reviewed *before* the expensive work it shapes. Decisions become deliverables.
3. **Reuse seams** — when a portion of the work is a skill that could serve other outcomes, draw the Task line around that portion so its agent is a reusable specialist rather than logic welded into a one-off.
4. **Context load** — *watch item, not yet a signal:* whether "a specialist must hold its whole task comfortably" earns a place is undecided; observe real runs.

## Anti-Patterns

1. **Activity Mirroring.** Tasks that restate how a person would spend time instead of naming what exists when done. Test: no package in the gist means mirroring.
2. **Phantom Deliverables.** An output no later task consumes and nobody evaluates; feels productive, changes nothing. The backward audit catches these. *Scope:* applies to crafting work — procedural and bucket-of-tasks outcomes are legitimate shapes, not phantom farms.
3. **Bundled Decisions.** A consequential choice buried inside a production task, made silently mid-work instead of reviewed before the expensive work it shapes.
4. **Uniform Slicing.** Cutting by volume instead of by the nature of the work. Even slices look organized and review terribly.
5. **Kitchen-Sink Tasks.** One task spanning research, deciding, producing, and verifying; its agent cannot specialize and its package cannot be judged cleanly.
6. **Unjustified Parallelism.** Branching without independence, fan-out without synthesis, or handoffs left implicit. Parallelism justified by the work's shape is first-class — see Pipeline Planning; what stays an anti-pattern is parallelism the decomposition cannot defend.

## Recipes v0

Recipes suggest; the planner adapts, blends, or discards with stated reasoning. None is a skeleton.

1. **Artifact Production, full form:** Clarify → Research → Cognitive Structure → Package Aesthetic & Format Fundamentals Vision → Structure to Package → Elaborate → Fit & Finish. Once a format standardizes, this simplifies toward Clarify → Structure → Elaborate → Package; per-artifact-type variants accrue as they are learned.
2. **Estate Improvement:** Inventory → Assess → Research → Decide → Execute → Verify — with a Feedback gathering-and-incorporation element whose position floats.
3. **Comprehensive Research:** extensive, analysis-rich reports produced as a matter of course. Demands a specialist tuned to user's report preferences.
4. **Spiking:** cut a spike scoped to the single dimension that teaches the most; sequence multiple spikes by information value; evaluate; accrue every learning to the larger picture. Spikes teach — they never ship.
5. **Operations cadence:** placeholder. Seed: Keep The Lights On (daily service-operational check). Shaped when real Operations arrive.
6. **Two-Hat inside Tasks:** draft → review → revise as within-task structure via the Review field — never separate tasks.

## Characteristics & Standing Sensings

**Understand the work's essential nature first** — artifact type, novelty versus routine, where uncertainty concentrates, aesthetic stakes, dependence on external best practices, feedback availability. This understanding is usually *drawn out of user* through the interview, and eventually from other sources. Characteristics indicate which recipes may help.

**Standing sensings — always-on judgment checks during any planning:**

1. Would best-practices or best-available-tools research pay here?
2. Would an early prototype scoped to one particularly tricky design dimension buy outsized upstream insight?
3. Where does feedback gathering and incorporation belong this time?
4. Is this format standardized enough yet to shed ceremony?

Derivation of tasks and steps is as much an intuitive, intelligent, high-craft process as any other aspect of productivity; agents doing it are empowered accordingly — principles over procedure, reasoning stated.

## Pipeline Planning — multi-agent decompositions

Confidence-Forward Selection's default output is a ladder — a linear confidence sequence. When the work's shape warrants it, the output is a **pipeline**: a directed acyclic decomposition where independent specialist tracks run in parallel and a synthesis close merges them. Reference pattern, mined from open-multi-agent (`repos/aitools/open-multi-agent/`, reference only — never a runtime dependency): one goal decomposes into parallel stable-role specialists, each with schema-precise outputs, and an aggregator waits for every track before merging the record. The meeting-record and security-review exemplars: three parallel reviewers (summary, action-items, sentiment; attack-surface, data-security, supply-chain), one synthesizer, one report.

**Pipeline shapes.**

1. **Fan-out / fan-in.** Independent specializations in parallel, one synthesizer closes. The canonical shape.
2. **Chain.** Linear handoffs where each stage's contract feeds exactly one successor — a ladder with explicit contracts.
3. **Hybrid.** Parallel tracks around linear segments; synthesis may be staged (partial merges before the final close).

**When a pipeline beats a ladder** — all three required, and the planner states the reasoning per decomposition:

1. **Independence.** The work partitions into specializations that neither consume each other's outputs nor share a consequential decision.
2. **Specialization mass.** Each partition is sizable enough to carry its own specialist's craft — a fragment nobody would judge alone stays a Step.
3. **Synthesis is craft.** Merging the tracks is itself a judgment act worth its own agent and Review — if synthesis is mere concatenation, a ladder with an assembly step is simpler and better.

When in doubt, ladder. Pipelines cost coordination: contracts to draft, tracks to track, a merge to judge. That cost is paid only when the three tests pass.

**Contract discipline — first-order.** Every edge in the DAG is a declared handoff contract: the producer's Output Essentials must satisfy the consumer's Expected Input, both written precisely enough that a cold executing agent needs nothing beyond the file. "The findings" is not a contract; "a triaged table of vulnerabilities with severity, location, and one-line evidence per row" is. Vague handoffs are a plan defect on par with a missing task. Contract precision scales with handoff count and agent coldness: single-agent linear tasks keep lightweight fields; multi-track pipelines get full contracts on every edge.

**Stable roles.** Pipeline specialists are conceived as reusable roles (attack-surface reviewer, sentiment specialist), not one-off task-doers — the reuse seam signal applied to teams. The synthesizer's charter names its judgment: what it resolves when tracks conflict, what it merges silently, what it escalates.

**Backward audit, pipeline form.** From the final synthesis backward: every track's output consumed by the merge, every merge input produced by a track, no orphan branches, no missing prerequisite. Parallel tracks that turn out to share a hidden dependency get re-chained — independence claims must survive the audit.

## Proposal Craft — plans and their files

Governs every implementation plan and proposal any Deskflow skill or agent produces, wherever it runs.

**Chat is primary; the file is archive.** A plan's content is always presented **in chat, in full** — user must never need to open a file to review a plan. The proposal file exists so the conversation survives: it is written after presentation, carries the same content plus provenance, and is linked from the chat-history entry. Plans and drafts are different species: a plan is conversation and lives in chat; a draft of a file to be created (code, a skill, a config) is an artifact user opens for review. Never confuse the two — never say "I've written the proposal to X" in place of presenting the plan.

**Every proposal names its triage call.** From the deskflow skill's reuse triage, stated at the top with one line of reasoning:

1. **Human-primary** — user does it; the plan is about preparation and companionship.
2. **Chat-native** — real AI leverage, too circumstance-unique to justify a specialization; plan and execute in conversation.
3. **Build the specialist** — the essential activity recurs with craft stakes; the plan includes conceiving or commissioning the reusable skill or agent.

The call is made even when obvious — one line costs nothing, and the habit is the point.

**Template.** Proposal files follow `deskflow/system/.proposals/proposal-template.md`: frontmatter and provenance header (source task, triage call), Understanding, Overview, Requirements, Affected Files, Implementation Steps (phased, ordering structural), Edge Cases & Risks, Verification Strategy, For Your Review (numbered judgment calls with leans), What Needs You (genuine forks only). The chat presentation mirrors the template exactly, minus frontmatter. Sections genuinely not applicable are marked `N/A` with a word of why — the template structures presentation, never replaces thinking.

**Source linkage.** Every proposal links the task or desk item that commissioned it. A proposal whose origin can't be traced is an orphan.

**Review anatomy.** The Attention-Call Anatomy applies in full: headline with the cost, numbered judgments with leans on their own lines, forks reserved for what only user can decide.

## Interview Bandwidth Craft

Governs every exchange where an agent needs thinking from user: Epicflow planning, outcome clarification, task review, agent conception, and any other moment where the conversation's quality directly sets the plan's quality. This is the underlying skill excellence that makes or breaks the deskflow system.

**Core principle.** Read what altitude user's thinking is at from what they have already written, meet them there, externalize the maximum volume of their thinking per exchange through wide invitations and demonstrated understanding, and narrow only as their own replies naturally narrow. Each exchange is Confidence-Forward Selection applied to the conversation: it materially advances the plan (the agent now knows more) and epistemically raises confidence that the plan tracks user's real intent (user saw their thinking reflected and corrected it).

**1. Bandwidth-first exchanges.** Every call to user is designed to get the largest right-sized chunk of their thinking externalized in one reply. Narrow single-detail questions are almost always wrong because they cap bandwidth at one fact per round trip. When an Epic or outcome has little written, the right opening is wide: show user what they wrote, ask them to tell the story of what this is and what done looks like, and explicitly invite as much depth as they want to share. User decides the altitude; the agent listens at whatever altitude user speaks.

**2. Demonstrate understanding, then deepen.** After user replies, the agent's next move is never another question cold. First, a concise playback of what the agent now understands — the desired outcome, the nature of the work, what a rough note probably meant given everything user said — presented as something to correct or confirm in passing, not as a gate. Then, and only then, the next question, which is at the *next* natural layer down: what does the first major move look like to you, and what else of the picture do you already see? Reflect, then draw out more, always signaling that more is welcome. This is the expert journalist's rhythm: charming, incisive, concise, coaxing the right details at the right level and depth.

**3. Hypothesize from context, never interrogate for atoms.** Every piece of context user has already given is used to reduce questions to genuine uncertainties. When user wrote "Write report" under an audit Epic with nothing else listed, a competent reader can hypothesize: the report is probably the final deliverable, not an interim task. State the hypothesis as part of the playback ("it sounds like the report is the end product of the whole audit, not a step along the way — is that right?") instead of asking user to classify from scratch. Interrogating for atoms — "What is the audience?" "What is the scope?" — optimizes for the AI's planning template, not for user's thinking bandwidth.

**Anti-patterns specific to this craft:**

1. **Template-backward questioning.** Asking questions whose answers fill the AI's own internal fields rather than externalizing user's thinking. Symptom: the questions could be asked identically for any Epic regardless of what user already wrote.
2. **Atom-per-round-trip.** One narrow question eliciting one fact, when a wide invitation would have yielded a paragraph of rich context in the same exchange.
3. **Cold follow-up.** Asking the next question without first demonstrating what the previous answer taught. User has no evidence their thinking landed; trust erodes; answers get shorter.
4. **Ignoring altitude.** User writes a high-level vision statement and the agent responds with detail questions. User writes implementation specifics and the agent asks about purpose. Meet the altitude user is at, then navigate from there.

## Agent Bones — conceiving specialists

For each specialist task: **derive the role from the register** (the craft the production demands, not the topic it touches); **generalize by stripping nouns** — "rewrites onboarding docs" becomes "doc-set rewriter given an assessment and a style standard" — then check what else across the epics could use it and name at the generalized level; **check kinship** against the fleet scan; **write the bones** into the `[Agent]:` attribute:

- `[Role]:` one line. `[Craft]:` the two or three skills excellence requires. `[Inputs]:` / `[Outputs]:` contracts. `[Gates]:` where it stops for review. `[Reuse]:` what else it serves. `[Kin]:` fleet relatives.

Enough bone structure that a later /agent-creator commission starts warm instead of cold. User participates deeply in agent conceiving, designing, and refining, especially early — bones are proposals for that collaboration, not fiat.

## Statement Elevation Classes

Every elevation change is classified by one question — *is meaning at stake?* No (casing, tense, format compliance): silent. Possibly (rewording that could shift intent): numbered, one line of why, standing if unanswered. Unelevatable without guessing: a fork. The hard rule: an elevation must read as user's thought sharpened, never replaced.

**Gist and statement travel as a pair.** Every proposed Task Statement arrives with its proposed Task Gist beside it; both are numbered and independently vetoable, and both stand together if unanswered. The gist is not derived noise — it is the line's headline on the desk and gets the same meaning-at-stake scrutiny as the statement.

**Gathering assembly.** Desk bullets and statements are many-to-many: one paragraph of user's writing may decompose into several statements, and one statement may draw on fragments written under different items, in different sections, or on different days. When elevating, gather every fragment bearing on the item before proposing — including fragments under other items, in One-offs & Inbox, and in prior desks when the same thread visibly continues. Stitching is normal and expected. The result is recorded as the statement's Raw Prompt Gathering in the owning epic's `raw-prompts.jsonl` (fundamentals §6a): verbatim within each fragment, each fragment provenanced to its source desk, on trial, judged on real runs.

## Self-Improvement Settings

**Signal collection.** Sessions tag sentiment-heavy exchanges in their event files with a `signal` event: `Time | Ref | signal | "User said the survey question format was much better this way"`. Sessions already write events; this adds one vocabulary word. The self-improver reads these rather than scanning full chat histories.

**Trigger, two paths:**
- **Invokable:** `/deskflow-improve` — user runs it when they want a self-improvement pass now.
- **Automatic:** the engine counts `signal` events across all sessions since the last improvement run; when the count crosses a threshold (default: 10), it spawns the improver session at the next render cycle.

**Implementation mode:** `approval-first` (default) or `auto-implement` (opt-in).
- **approval-first:** the improver session appears in the chat list with a ⚡ prefix, surfaces in For Your Review on the TASKBOARD, and waits for user's verdict before writing any changes.
- **auto-implement:** high-confidence changes are written immediately; a Recent Self-Improvements section on the TASKBOARD records each with timestamp, summary, plan link, and commit hash for easy review or revert.

**Values live in `deskflow/system/SETTINGS.md`** (single writer: user): signal-threshold, improvement-mode, and epic-sessions all configure there.

## Persistence Contract

Binds every Deskflow session and every Deskflow-adjacent skill and agent. The rule is absolute: every write is persisted, immediately, with no judgment applied to whether the write was "meaningful." A file an agent wrote that exists only locally is a file a crash can take — the trail is the system working.

1. **Every write is committed and pushed immediately.** Proposal files, plan files, stamped desks, ledgers, registry updates, events, improvements, scratch artifacts worth keeping — if a session wrote a file, that file is committed and pushed before the response ends. No batching across exchanges, no waiting to be asked, no significance threshold.
2. **Approval moments are their own commits.** When user approves a proposal or plan and it is published, that publication is committed on the spot as its own named write — never folded into unrelated later work. The git trail mirrors the conversation's decision points.
3. **Scoped adds.** `git add` only the paths written in this exchange.
4. **Message format.** `[{area}]: {Verb}s {description}`, under 72 chars, imperative — the shared workspace convention. Area is `deskflow` for system and steward writes, `taskflow-{slug}` for epic plan writes, `self-improve` for self-improvement runs, or the epic slug for epic-folder artifacts.
5. **Push failure protocol.** On rejection: `git pull --rebase`, retry once. Still rejected: notify user and move on — a run never blocks on git.
6. **Suppression.** `skip-chat-save` and `fast-mode` suppress per the workspace's command-prefix rules; chat-history saving stays governed by the shared workspace rules, which this contract does not duplicate.
