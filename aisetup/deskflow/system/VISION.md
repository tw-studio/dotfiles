---
name: VISION.md
version: 00.01
updated: 2026-08-01
---

# Deskflow Vision

What this system is for and how user wants to work. This is the essence file: when any artifact, agent, plan, or conversation seems to drift, this is what it drifted from.

## The Premise

Course-correcting final outputs when they are off base, in big ways or small, is orders of magnitude more difficult than course-correcting earlier, more tractable artifacts, especially artifacts that make the *thinking behind the design decisions* clear, because that thinking is the essence of everything downstream of it. A finished draft with a hundred problems costs an exhausting read, a hundred pieces of feedback, an AI's imperfect interpretation, and a fresh draft with a hundred new problems. A wrong gist costs one sentence. So the system moves user's judgment upstream, onto small artifacts that expose reasoning, where corrections are cheap. Handing more to AI is the goal; staged early review is how handoff becomes safe and fast.

## The Working Day

One page runs the day: the DESK. Its shape is a ritual: Operations first, today's curated Epics, capture inboxes, waiting, done, meetings. User thinks, plans, and even executes inline, right where each thought belongs, with checkboxes, glyphs, and bare agent names as the whole notation.

One command flows the work: `/deskflow`. It reconciles the desk with the system silently, surfaces only what needs user in one kickoff report, and spawns a session per Epic. Each session drives its Epic's flow: plans with user when unplanned, delegates, reviews, and calls for user only when user's move is the highest-leverage next action, prepared to review-ease before the call. User flits session to session, spending small atomic judgments, while the TASKBOARD strip keeps every Epic's current task and focus visible at a glance. When an Epicflow concludes, the next Epic's session spawns itself. Everything is markdown and git; any crash resumes from the trail.

## The Standards That Guard It

- **Attention scheduling.** The system's job is to schedule user's attention: early calls at upstream gates, one decision moment per call, each prepared before it is made. Excellence to user's standard always outranks minimizing user's time; minimizing time improves run over run within that constraint.
- **Two-hat standard.** Work advances only when a second hat is satisfied; user holds most hats early, reviewer agents take the seats one by one; exceptions declared, never silent.
- **Review-ease.** Atomic decisions, visible reasoning, natural top-to-bottom flow, plain English, diagrams welcome, length proportional to the decisions carried.
- **Agentic decomposition and Confidence-Forward Selection.** Right-sized deliverables for right-sized reusable specialists, chosen move by move for dual yield: material progress plus confidence that the end deliverable is on track to excellence. Buildable agents count as available hands.
- **Ambiguity gate.** Ambiguous wording gets confirmed before processing, at any autonomy level.
- **Continuous improvement over dogma.** Craft lives in a living library; formats shed ceremony as they standardize; real runs drive revisions.
- **Single-writer, no exceptions.** Every file has exactly one writer; conflict prevention is structural.

## The Maturation Path

Early: user holds most review hats, participates deeply in conceiving agents, runs commands by hand. Over time: reviewer agents take seats, the craft library accrues recipes and archetypes from real runs, dispatch gets scheduled, and the system helps identify outcomes rather than only receiving them. Each upgrade bolts on after the manual flow proves itself.

## What This Is Not

Not one-shot generation with review at the end. Not brevity-metric review. Not fixed skeletons. Not interview-dependent agents: they stand alone in method, propose complete, and reserve questions for genuine forks. Not a batcher: sessions never accumulate finished stages before calling. Not machine-voiced: everything written to user obeys voice.md, compressing ideas and never grammar. And not a hobby: shortest path to a running system, leaning on what already exists.
