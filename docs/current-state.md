# Current State — Sweet Home OS

**Date:** 2026-06-01
**Branch:** `claude/adoring-bell-dv270`
**Phase:** 1 (scaffold complete, synced to work canonical baseline)

---

## Authoritative Summary

Use this document when a new session appears to see conflicting summaries from older branches. This is the ground truth.

## Implemented Runtime Features

- Six Chinese JRPG-style quest cards load from `data/quests.json` and use `xp_reward` as the canonical reward field.
- The guild hall UI supports selecting, accepting, and reporting completion for quests.
- Completing a quest increments local `total_xp` in `scripts/guild_hall.gd`.
- Six decorations load from `data/decorations.json` and unlock by `unlock_xp`, including first-wave Kenney target paths for `guild_planter` and `wooden_shelf`.
- Newly unlocked decorations are queued so only one overlay appears at a time.
- `SoundManager` plays a procedural 8-bit arpeggio for decoration unlocks.
- `World/FloorTileMapLayer` provides a 16x16 procedural TileMapLayer grid, and its floor color tweens across XP bands.
- `HeroActor` walks with arrow keys/WASD, faces direction, and interacts with `QuestBoardObject` via Space/Enter.
- Hero evolution scaffold selects the highest stage whose `min_xp` ≤ current XP.

## Do Not Regress

- `World/FloorTileMapLayer` must exist and support `floor_color` tween.
- `World/YSortLayer` must exist with `y_sort_enabled = true`.
- `HeroActor` must walk and interact with `QuestBoardObject`.
- Decoration unlock queue must remain (one overlay at a time).
- `SoundManager.play_unlock_decor_sound()` must be callable.
- `data/quests.json` uses `xp_reward` as canonical reward field.
- `data/decorations.json` uses `unlock_xp` as canonical threshold field.

## Data Schemas (canonical)

### quests.json fields
`id`, `title`, `description`, `xp_reward`, `category`, `estimated_minutes`, `family_note`

### decorations.json fields
`id`, `name`, `description`, `unlock_xp`, `scene_position`, `color`, `shape`, `sprite_path`

### hero_evolution.json fields
`id`, `stage`, `name`, `min_xp`, `max_xp`, `sprite`, `required_total_xp`

## What Is NOT Yet Done (Phase 2+)

- PIN verification for parent confirmation (P2-001)
- Real Kenney audio SFX assets (P2-002)
- Animated hero sprite sheets (P2-003)
- Actual Kenney decoration sprites (P2-002)
- Local save/load persistence (P2-004)
- Particle effects on unlock (P2-005)

## Known Limitations

- `HeroActor` sprite loads gracefully fail (no texture = just geometric fallback) until real assets land.
- `DecorPlaceholder` falls back to coloured geometry for all 6 decorations since Kenney assets are not yet staged.
- SFX are programmatic sine-wave beeps; no audio files referenced.
