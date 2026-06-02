# Current State — Sweet Home OS

**Date:** 2026-06-02
**Branch:** `claude/intelligent-hawking-gTW60`
**Phase:** 1+ / Phase 4.4 Polish Baseline

---

## Authoritative Summary

Use this document when a new session appears to see conflicting summaries from older branches. This is the ground truth.

## Implemented Runtime Features

- Six Chinese JRPG-style quest cards load from `data/quests.json` and use `xp_reward` as the canonical reward field.
- The guild hall UI supports selecting, accepting, and reporting completion for quests, plus a Family Help panel that explains the parent PIN, daily accepted-quest reset, and local caregiver PIN settings.
- Reporting completion opens `ParentGateOverlay`, and XP is granted only after the caregiver PIN gate emits `verified`; do not replace this with a child-solvable math challenge.
- Six decorations load from `data/decorations.json` and unlock by `unlock_xp`, including original first-wave sprites for `guild_planter` and `wooden_shelf`. `guild_planter` and `wooden_shelf` have `blocks_movement`, `collision_size`, and `collision_offset` data-driven blocker fields.
- `SaveManager` persists `total_xp`, accepted quest data, shown decoration IDs, `last_play_date`, and local `parent_pin` to `user://save/sweet_home_save.json`; when a new calendar day starts, only the accepted quest is cleared so XP and unlock history stay positive.
- Newly unlocked decorations play a small scale-pop highlight and are queued so only one overlay appears at a time.
- `SoundManager` plays a procedural 8-bit arpeggio for decoration unlocks and quiet procedural footstep SFX.
- `World/FloorTileMapLayer` provides a 16×16 procedural TileMapLayer grid; its floor color tweens across XP bands.
- `World/WallTileMapLayer` renders fallback-first wall bands (16×16 tick marks) aligned to `World/Boundaries`; visual only — physics still lives in `Boundaries`.
- `HeroActor` loads stages from `data/hero_evolution.json`, supports sprite-first rendering, falls back to procedural geometric idle/walk animation with squash-and-stretch, procedural footstep dust, and a non-punitive collision feedback flash; the HUD shows the current hero stage and next XP growth target.
- The hero can interact with an in-world `QuestBoardObject` to reveal the quest UI.
- `World/CollisionDebugOverlay` is hidden by default and can be toggled from the Family Help panel; it visualizes hall bounds, WallTileMapLayer guide rectangles (orange `#c49a6c`), hero spawn safety zone, quest board access zone, and decoration blocker rectangles using the same spatial assumptions as `tools/verify_layout_safety.py`.

## Do Not Regress

- `World/FloorTileMapLayer` must exist and support `floor_color` tween.
- `World/WallTileMapLayer` must exist with `get_wall_rects()`.
- `World/YSortLayer` must exist with `y_sort_enabled = true`.
- `World/CollisionDebugOverlay` must draw wall guide rects in addition to hall/spawn/board/blocker rects.
- `HeroActor` must walk and interact with `QuestBoardObject`.
- Decoration unlock queue must remain (one overlay at a time).
- `SoundManager.play_unlock_decor_sound()` and `SoundManager.play_footstep_sound()` must be callable.
- `ParentGateOverlay` must gate XP grant behind caregiver PIN verification — not a math gate.
- `data/quests.json` uses `xp_reward` as canonical reward field.
- `data/decorations.json` uses `unlock_xp` as canonical threshold field; `guild_planter` and `wooden_shelf` must have `blocks_movement: true`.
- Save file at `user://save/sweet_home_save.json` must persist `total_xp`, `accepted_quest`, `shown_decoration_ids`, `last_play_date`, `parent_pin`.
- `tools/verify_layout_safety.py` must include `WALL_GUIDE_RECTS`, `BOUNDARY_COLLISION_RECTS`, and `validate_wall_guides()`.

## Data Schemas (canonical)

### quests.json fields
`id`, `title`, `description`, `xp_reward`, `category`, `estimated_minutes`, `family_note`

### decorations.json fields
`id`, `name`, `description`, `unlock_xp`, `scene_position`, `color`, `shape`, `sprite_path`
Optional blocker fields: `blocks_movement`, `collision_size`, `collision_offset`

### hero_evolution.json fields
`id`, `stage`, `name`, `min_xp`, `max_xp`, `sprite`, `required_total_xp`

## Important Files

| 路徑 | 說明 |
|------|------|
| `project.godot` | main scene、input mapping、GL Compatibility、`SoundManager` / `SaveManager` autoload |
| `scenes/guild_hall.tscn` | 主場景，含 quest UI、Hero Status HUD、Family Help panel、UnlockPanel、WallTileMapLayer、CollisionDebugOverlay |
| `scenes/parent_gate_overlay.tscn` | 家長 PIN 確認 overlay |
| `scripts/guild_hall.gd` | quest loop、parent-gated XP、save/load、Hero Status HUD、Family Help、decor refresh、queued unlock、background tween |
| `scripts/hero_actor.gd` | hero evolution、keyboard locomotion、squash-and-stretch、footstep dust、collision feedback flash |
| `scripts/save_manager.gd` | `user://save/sweet_home_save.json` local save/load，含 `last_play_date` / `parent_pin` |
| `scripts/parent_gate_overlay.gd` | 家長 PIN gate，有 `verified` / `cancelled` signal |
| `scripts/wall_tile_map_layer.gd` | fallback wall bands，與 `World/Boundaries` 對齊，含 `get_wall_rects()` |
| `scripts/collision_debug_overlay.gd` | 開發用 overlay，顯示 hall / wall guide / spawn / board / blocker rectangles |
| `scripts/decor_placeholder.gd` | sprite-first 裝飾渲染，帶幾何 fallback 與 `MovementBlocker` collision |
| `scripts/grid_world.gd` | TileMapLayer 16×16 棋盤格，`floor_color` tween，`create_wall_collision_blocker()` scaffold |
| `assets/original/decor/guild_planter.png` | 第一波原創裝飾 PNG |
| `assets/original/decor/wooden_shelf.png` | 第一波原創裝飾 PNG |
| `tools/verify_current_state.py` | baseline 完整性驗證 |
| `tools/verify_layout_safety.py` | decoration blocker 安全驗證 + `validate_wall_guides()` wall alignment |
| `tools/validate_asset_ledger.py` | asset 授權 ledger 驗證 |
| `tools/godot_smoke_test.py` | optional Godot headless smoke test |

## Suggested Next Work

1. **Wall & Boundary Refinement** — 加強 TileMapLayer walls / 家具 collision，不破壞 fallback floor / Y-sort。
2. **Godot smoke test CI wiring** — 在有 Godot binary 的 CI runner 執行 `python3 tools/godot_smoke_test.py --require-godot`。
3. **Original sprite refinement** — 依家庭測試回饋微調 `guild_planter.png` / `wooden_shelf.png`。

## Known Limitations

- `HeroActor` sprite loads gracefully fail (no texture = geometric fallback) until real assets land.
- `DecorPlaceholder` falls back to coloured geometry for all 6 decorations since Kenney assets are not yet staged.
- SFX are programmatic sine-wave beeps; no audio files referenced.
- This cloud session branch (`claude/intelligent-hawking-gTW60`) is separate from the user's local `work` branch; they should be kept in sync via PR.
