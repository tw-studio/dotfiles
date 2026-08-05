---
name: SETTINGS.md
version: 00.01
updated: 2026-08-02
---

# Deskflow Settings

Single writer: user. Agents and the engine read these at run start.

| Setting | Value | Meaning |
|---|---|---|
| epic-sessions | 1 | Epic driver sessions /deskflow spawns or drives per run, top of EPICS.md down |
| signal-threshold | 10 | Signal events that trigger an automatic self-improvement run |
| improvement-mode | approval-first | approval-first or auto-implement |
