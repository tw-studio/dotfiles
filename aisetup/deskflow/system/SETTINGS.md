---
name: SETTINGS.md
version: 00.02
updated: 2026-08-03
---

# Deskflow Settings

Single writer: user. Agents and the engine read these at run start.

| Setting | Value | Meaning |
|---|---|---|
| copilot-cli-effort | max | Default effort for spawned Copilot CLI sessions |
| copilot-cli-model | openai/gpt-5.6-luna | Default model for spawned Copilot CLI sessions |
| epic-sessions | 10 | Epic driver sessions /deskflow spawns or drives per run, top of EPICS.md down |
| improvement-mode | approval-first | approval-first or auto-implement |
| signal-threshold | 10 | Signal events that trigger an automatic self-improvement run |

## Reference: Copilot CLI settings

Model catalog (mirrors .zshrc MARK: Copilot CLI):
  openai/gpt-5.6-luna        — $0.05 , 51 iq = 1020 , md*,h,xh,mx , always max
  z-ai/glm-5.2               — $0.59 , 51 iq = 86   , h*,xh
  moonshotai/kimi-k3         — $0.86 , 57 iq = 66   , h,mx*
  anthropic/claude-fable-5   — $3.15 , 60 iq = 19   , h*,xh,mx
  anthropic/claude-opus-4.6  — $2.15 , 44 iq = 20   , h*,mx
Invocation contract: deskflow/system/install/skills/deskflow-copilot-cli/SKILL.md
