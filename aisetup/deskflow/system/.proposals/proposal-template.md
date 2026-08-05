---
name: proposal-template
version: 00.00
updated: 2026-08-05
---

# Proposal Template

Copyable skeleton for proposal files, per the craft library's Proposal Craft section. The chat presentation mirrors this structure exactly, minus frontmatter — chat is primary, the file is archive. Sections genuinely not applicable are marked `N/A` with a word of why. Handoff Contracts is required: answer it even when the answer is "none — single-agent plan."

```markdown
---
name: {NN.VV}-{slug}-proposal
version: {NN.VV}
updated: {date}
epic: {Display Name}
status: draft — awaiting user review
---

# Proposal: {Title}

**Source:** {Task Gist} — {desk or epic ledger, linked}, approved {date}
**Triage:** {1 Human-primary | 2 Chat-native | 3 Build the specialist} — {one line of reasoning}

## Understanding

{1–2 sentences restating the task as understood — the confirmed-understanding gate, in the file.}

## Overview

{2–3 sentences: what will be built or changed and why.}

## Requirements

{Numbered list of what the implementation must achieve.}

## Affected Files & Components

{Files to modify with what changes; new files with purpose; indirectly affected files. Explicitly-untouched notes when relevant.}

## Handoff Contracts

{Per handoff between tasks/agents: producer's Output Essentials → consumer's Expected Input, precise enough for a cold agent. `N/A — single-agent plan` when there are no handoffs.}

## Implementation Steps

{Phased groups — phase names carry the ordering, steps within are concrete and actionable, each with brief why when non-obvious.}

## Dependencies & Order

{Cross-phase constraints and their reasons.}

## Edge Cases & Risks

{Numbered: failure modes, assumptions, where a different approach might be preferred.}

## Verification Strategy

{How the result gets checked end to end — including live exercises and cold-agent traces where relevant.}

## For Your Review

{Numbered judgment calls, each with the lean on its own line — vetoable by number, standing if unanswered.}

## What Needs You

{Genuine forks only — where user's values or private context decide. Numbered, options on their own lines.}
```
