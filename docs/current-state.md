# Current Repository State

This repository is **not** the minimal Phase 1-only skeleton. The current canonical branch is `claude/blissful-euler-TGSuP`, and the current baseline includes the quest-board loop plus local XP, queued decoration unlocks, hero evolution/locomotion scaffolding, procedural SFX, and asset-license tooling.

Use this document when a new session appears to see conflicting summaries from older branches or prior agent runs.

## Canonical Baseline

- Branch: `claude/blissful-euler-TGSuP`
- Main scene: `res://scenes/guild_hall.tscn`
- Godot target: 4.3 or newer
- Current scope: Phase 1 prototype with growth-feedback add-ons

## Implemented Runtime Features

- Quest cards load from `data/quests.json`.
- The guild hall UI supports selecting, accepting, and reporting completion for quests.
- Completing a quest increments local `total_xp` in `scripts/guild_hall.gd`.
- Decorations load from `data/decorations.json` and unlock by `required_total_xp`.
- Newly unlocked decorations are queued so only one overlay appears at a time.
- `SoundManager` plays a procedural 8-bit arpeggio for decoration unlocks.
- The background color tweens across XP bands.
- `HeroActor` loads stages from `data/hero_evolution.json`, supports sprite-first rendering, and falls back to procedural geometric idle/walk animation.

## Important Files

- `README.md` — top-level project overview and run instructions.
- `project.godot` — Godot project config and `SoundManager` autoload.
- `scenes/guild_hall.tscn` — main guild hall scene.
- `scripts/guild_hall.gd` — quest board, XP, decoration unlock queue, background tween, and hero XP update wiring.
- `scripts/decor_placeholder.gd` — sprite-first decoration renderer with geometric fallback.
- `scripts/hero_actor.gd` — hero evolution, keyboard locomotion, facing state, and fallback animation.
- `scripts/sound_manager.gd` — procedural unlock SFX.
- `tools/validate_asset_ledger.py` — checks asset-staging documentation markers.
- `tools/verify_current_state.py` — checks that the advanced baseline is present.

## Do Not Regress

Do **not** replace this branch with a smaller Phase 1-only skeleton unless explicitly requested. In particular, do not remove:

- `data/decorations.json`
- `data/hero_evolution.json`
- `scripts/decor_placeholder.gd`
- `scripts/hero_actor.gd`
- `scripts/sound_manager.gd`
- queued unlock overlay nodes in `scenes/guild_hall.tscn`
- `tools/validate_asset_ledger.py`

## Suggested Next Work

1. Add parent confirmation before quest completion grants XP.
2. Add local save/load for `total_xp`, accepted quest, and shown decoration IDs.
3. Import exactly one approved Kenney decoration after updating `docs/research/asset-license-ledger.md`.
4. Add a `godot --headless --path . --quit` smoke test when Godot is available in CI.
