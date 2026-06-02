# Sweet Home OS 新對話接手提示

請接手 Sweet Home OS。repo 在 `/workspace/sweet-home-os`，canonical branch 是 `work`。

## 目前狀態

這不是最小 Phase 1 骨架，而是 **Phase 4.4+ Polish Baseline**：Godot 4.3+ 公會大廳、資料驅動任務、caregiver PIN gate（Phase 2 已完成）、local XP、SaveManager 存檔、queued decoration unlock、hero evolution/locomotion、squash-and-stretch、procedural `FootstepDustPuff`、quiet procedural footstep SFX、collision feedback flash、可互動任務佈告欄、data-driven `MovementBlocker` collision、`WallTileMapLayer` fallback walls、`CollisionDebugOverlay`（含 wall guide rectangles）、`create_wall_collision_blocker()` scaffolding、原創 pixel-art 第一波裝飾，以及 Kenney Phase 4 asset-staging 文件與驗證工具。

請先閱讀 `README.md` 與 `docs/current-state.md`，不要回退或刪除以下任何部分：
- decorations / hero evolution / quest board interaction
- parent gate / SoundManager / SaveManager
- asset ledger / original sprite directory
- `World/FloorTileMapLayer`、`World/WallTileMapLayer`、`World/YSortLayer`、`World/CollisionDebugOverlay`
- `tools/verify_layout_safety.py`（含 `validate_wall_guides()`）

## Short Chinese Opening Prompt

請先閱讀 `docs/current-state.md`，再執行 `python3 tools/verify_current_state.py`，確認 baseline 完整後再開始工作。

## 任務循環說明

- Quest board loop：選任務、接任務、通過 caregiver parent PIN 後增加 local `total_xp`，並用 `SaveManager` 保存進度與 `last_play_date`；跨日只清除已接任務，不扣 XP 或解鎖。**不要把 PIN gate 改成小孩可自行解答的數學題。**
- HUD 內有 Family Help panel，說明 parent PIN、daily accepted-quest reset，以及不要比較/不要懲罰的家庭 tone。
- `World/FloorTileMapLayer` 負責 16×16 棋盤格 TileMapLayer，floor_color 會隨 XP 段位 tween 變色。
- `World/WallTileMapLayer` 繪製與 `World/Boundaries` 對齊的 fallback wall bands（視覺用）。
- `World/CollisionDebugOverlay` 可透過 Family Help 的 Collision Debug 按鈕顯示 hall bounds、wall guide rectangles、hero spawn safety、quest board access、decoration blockers，僅供成人 QA / layout tuning 使用。

## 驗證指令

```bash
python3 tools/verify_current_state.py
python3 tools/verify_layout_safety.py
python3 tools/validate_asset_ledger.py
python3 tools/verify_first_wave_pngs.py
python3 -m json.tool data/decorations.json >/dev/null
python3 -m json.tool data/hero_evolution.json >/dev/null
python3 -m json.tool data/quests.json >/dev/null
python3 -m py_compile tools/validate_asset_ledger.py tools/verify_current_state.py tools/verify_layout_safety.py tools/godot_smoke_test.py
python3 tools/godot_smoke_test.py
git diff --check
```

若環境有 Godot：

```bash
python3 tools/godot_smoke_test.py --require-godot
```

若 `godot` binary 不存在，請在回報中標示為環境限制，而不是程式錯誤。

## 重要檔案清單

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

## 建議下一步

1. **Wall & Boundary Refinement** — 加強 TileMapLayer walls / 家具 collision，不破壞 fallback floor / Y-sort。
2. **Godot smoke test CI wiring** — 在有 Godot binary 的 CI runner 執行 `python3 tools/godot_smoke_test.py --require-godot`。
3. **Original sprite refinement** — 依家庭測試回饋微調 `guild_planter.png` / `wooden_shelf.png`。

## 回覆格式要求

- **全程中文回答**
- 每次變更後至少執行一次驗證指令
- 保持 Phase 4.4+ baseline，不要縮減
