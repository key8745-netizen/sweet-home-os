# Sweet Home OS

Sweet Home OS is a Godot 4.x prototype that frames household chores as warm JRPG guild quests for families.

This branch combines the Phase 1 quest-board skeleton with a queued growth-feedback loop: quest completion grants local guild XP, unlocks placeholder decorations, and celebrates new decor one overlay at a time.

## Canonical State

This repo is currently the advanced Phase 1 baseline: it includes the quest board plus local XP, queued decoration unlocks, hero evolution/locomotion scaffolding, procedural unlock SFX, and asset-staging docs. Do not reset it to a smaller Phase 1-only skeleton unless explicitly requested. See `docs/current-state.md` for the handoff checklist.

## Run

1. Open this folder in Godot 4.3 or newer.
2. Run the project. The main scene is `res://scenes/guild_hall.tscn`.

## Current Phase 1 Scope

- Load chore quests from `data/quests.json`.
- Show a simple guild quest board with a left-side task list and right-side detail panel.
- Let the child select, accept, and report completion for one quest.
- Add local guild XP when a quest is reported complete.
- Unlock placeholder decorations from `data/decorations.json`.
- Queue decoration unlock overlays and play a warm 8-bit arpeggio.
- Gently tween the guild hall background as XP grows.
- Keep the tone encouraging and non-punitive.

## Out of Scope for Phase 1

- Parent confirmation gates.
- Daily reset, save data, permanent achievements, and final decoration art.
- Final art, imported asset packs, or production UI polish.

## Hero Evolution

A sprite-first hero avatar scaffold is available in `scripts/hero_actor.gd`, `scenes/hero_actor.tscn`, and `data/hero_evolution.json`. It currently falls back to geometric breathing visuals until approved sprite sheets are imported.

## Growth Feedback

See `docs/growth-feedback.md` for queued unlock overlays, background tween rules, and family-safe tone guardrails.
