---
name: deskflow-copilot-cli
description: How to invoke the Copilot CLI in this workspace — bare invocation, model and effort overrides, translation from user's friendly phrasing to the exact command line — plus the Spawn Protocol for bringing agent-flow diagrams to life: named joinable sessions, skeptic gate loops, per-taskflow budgets, crash vs. rejection semantics. Use whenever a session needs to spawn, or advise on spawning, Copilot CLI sessions. Deskflow-origin skill, written for any session to pick up.
---

# Invoking Copilot CLI within Deskflow system

Contract for invoking the `copilot` CLI in this workspace. Read before spawning any CLI session.

## Default Invocation

Bare `copilot` is correct when no override is requested. User's shell wraps it with provider, API key, default model, and default effort — configured in the `Copilot CLI` section of user's `.zshrc`.

## Override Grammar

When user names a model or an effort, invoke with the explicit env-var form:

```
COPILOT_MODEL="{model-id}" copilot --effort {level}
```

Provider and API key env vars (`COPILOT_PROVIDER_BASE_URL`, `COPILOT_PROVIDER_API_KEY`) also exist and default correctly — do not touch them unless user explicitly asks.

Always use the explicit env-var form for overrides, never rely on shell functions — a session spawned programmatically (engine, background process) will not see them.

## Translation

User speaks in friendly names; you translate. Active defaults live in `deskflow/system/SETTINGS.md` (Copilot CLI section) — read them there; do not guess.

| User says | Model ID | Price per Task | IQ Index (highest effort) | IQ Value | Efforts (default*, preference^) |
|---|---|---|---|---|---|
| Luna / gpt-5.6-luna | `openai/gpt-5.6-luna` | $0.05 | 51 | 1020 | md*,h,xh,mx^ |
| GLM 5.2 | `z-ai/glm-5.2` | $0.59 | 51 | 86 | h*,xh^ |
| Kimi K3 | `moonshotai/kimi-k3` | $0.86 | 57 | 66 | h^,mx* |
| Fable 5 | `anthropic/claude-fable-5` | $3.15 | 60 | 19 | h*,xh^,mx |
| Opus 4.6 | `anthropic/claude-opus-4.6` | $2.15 | 44 | 20 | h*^,mx |

> md = medium, h = high, xh = xhigh, mx = max

When user names a model without an effort, apply that model's preference from the table (indicated by `^`). When user names an effort the model rejects, state the constraint and use the model's preference.

## Examples

- "Use Kimi K3" → `COPILOT_MODEL="moonshotai/kimi-k3" copilot --effort high`
- "Use Kimi K3 with effort high" → same
- "Use Luna" → `COPILOT_MODEL="openai/gpt-5.6-luna" copilot --effort max`
- No model named → bare `copilot` (defaults from SETTINGS.md via user's shell)

## Spawn Protocol

How an orchestrating session (steward or subagent) brings a ratified agent-flow diagram to life. Proven against CLI v1.0.78 on 2026-08-05.

### Session Shapes

| Shape | Invocation | Use for |
|---|---|---|
| Named interactive | `copilot -i "{birth prompt}" -n "{yymmdd}-{gist}" --agent {agent-file-stem} --allow-all-tools` | Subagent task sessions, skeptic gates — anything user may join or the orchestrator must re-enter |
| One-shot | `copilot -p "{prompt}" -s --allow-all-tools` | Mechanical node work with no assistance, no loop, no resume |

Rules:

- **Name every interactive session** `{yymmdd}-{gist}` — names are how anyone re-enters.
- **Re-entry is by name**: `copilot -r "{name}" -p "{follow-up}" -s --allow-all-tools` reaches the same session with its full history. Works for the orchestrator's follow-ups and for user joining a session.
- **`--agent` carries the protocol** — spawn with the agent file (e.g. `--agent deskflow-subagent`) so the birth prompt carries task content, not behavioral rules.
- **Never spawn unnamed.** An unnamed session is an unjoinable session.

### Skeptic Gate Loops

Gates are two-session loops, never self-critique:

1. Producer session delivers its interim output (staged at a known path).
2. Orchestrator spawns (or resumes) the skeptic session with the gate's instruction, the deliverable path, and the task's ask.
3. Skeptic fails it → orchestrator resumes the producer by name with the skeptic's required changes; producer revises and resubmits. Loop until pass.
4. **Bound — stagnation, not count:** productive revision loops run as long as each round addresses new feedback — ten productive revisions is the loop working. The cap applies to *stagnation*: three consecutive loops where the skeptic's objections are substantively the same → orchestrator escalates to user with the disagreement stated plainly. Never loop forever on the same ground.

### Session Roster

Every spawn is recorded in the spawning session's events file: `Time | #{tag} | spawn | name={session-name} role={role} model={model}/{effort}`. The roster is how the steward and the board know what is running.

### Budgets

- **Concurrency is per taskflow:** each task orchestrator runs at most 3 of its own node sessions at once; a fourth waits for a slot. Task-level concurrency is separate and user's call — many tasks may run concurrently, each with its own orchestrator and its own budget of 3.
- **System ceiling:** 1 deskflow orchestrator + per task (1 task orchestrator + up to 3 node sessions) = active tasks × 4 + 1.
- **Depth:** spawn depth never exceeds 2 within a taskflow (task orchestrator → node session). A node session needing further decomposition escalates rather than spawning.

### Failure Semantics

Crash and rejection are different events with different caps.

- **Crash** (session dies, errors, produces nothing usable): one restart, then the orchestrator reports to user. Never silently restarts a crashed session more than once.
- **Skeptic rejection** (output exists but does not pass the gate): the normal revision loop — iterate per the gate-loop bound above.
- A crashed node marks itself failed in the roster; its diagram dependents stay blocked; all other branches continue.

## Provenance

Live defaults are configured in user's `.zshrc` under `MARK: Copilot CLI`. This skill records the contract; when the two conflict, the `.zshrc` wins and this file should be updated.
