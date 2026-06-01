# Sweet Home OS

Sweet Home OS is a Godot 4.x household-management game with a cozy 2D JRPG aesthetic. Children play as adventurers who pick household chore quests from a family guild board. Parents confirm completion and the hero earns XP and unlocks guild decorations.

## Canonical State

The canonical branch is **work**. Do not reset it to a smaller Phase 1-only skeleton — it contains queued decoration unlocks, hero walk-and-interact scaffolding, and the full data/script baseline that subsequent sessions build on.

## Quick Start

1. Open the project in Godot 4.3+.
2. Run `scenes/guild_hall.tscn`.
3. Move the hero with arrow keys or WASD.
4. Approach the quest board and press Space/Enter to open quests.
5. Accept a quest, then report it complete to earn XP.

## Project Layout

| Path | Purpose |
|------|---------|
| `scenes/guild_hall.tscn` | Main scene |
| `scripts/guild_hall.gd` | Core runtime logic |
| `scripts/hero_actor.gd` | Walk, face, interact |
| `scripts/decor_placeholder.gd` | Sprite-first decorations with procedural fallbacks |
| `scripts/quest_board_object.gd` | Interactable in-world quest board |
| `scripts/sound_manager.gd` | Autoload SFX |
| `data/quests.json` | Quest card data |
| `data/decorations.json` | Decoration unlock thresholds |
| `data/hero_evolution.json` | Hero evolution stages |
| `docs/design-plan.md` | Product pillars and Phase 2 candidates |
| `docs/interaction-system.md` | Walk-up interaction design |

## Runtime Features

- Load Chinese JRPG-style quest cards from `data/quests.json`.
- Accept a quest, pass a lightweight parent PIN confirmation gate, and then earn local XP from each card's `xp_reward`.
- Unlock decorations from `data/decorations.json` when `total_xp` reaches their thresholds.
- Queue decoration unlock overlays so only one family-safe celebration appears at a time.
- Play a procedural 8-bit unlock arpeggio through the `SoundManager` autoload.
- Guild hall floor uses a procedural `TileMapLayer` (`GridWorld`) with XP-reactive color tweening.

## Hero Evolution

A sprite-first hero avatar scaffold is available in `scripts/hero_actor.gd`, `scenes/hero_actor.tscn`, and `data/hero_evolution.json`. It currently falls back to geometric breathing visuals until approved sprite sheets are imported.

## Growth Feedback

See `docs/design-plan.md` for queued unlock overlays, background tween rules, and family-safe tone guardrails.

## Validation

Run `python3 tools/godot_smoke_test.py` as the optional Godot headless smoke wrapper. It skips cleanly when no `godot` binary is installed; use `python3 tools/godot_smoke_test.py --require-godot` in CI runners where Godot is expected.

## New Session Handoff

Use `docs/new-session-brief.md` as the copy/paste opening prompt for a fresh agent session.
