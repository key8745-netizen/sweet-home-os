# Sweet Home OS 新對話接手提示

將此檔案內容貼到新 AI 對話的開頭。一律用繁體中文回答。

---

## 現況摘要（2026-06-01，Phase 1 + P2-001 完成）

Sweet Home OS 是 Godot 4.3+ 的家庭友善家務遊戲，採用 2D JRPG 公會大廳風格。

### 已實作

- 6 張中文 JRPG 任務卡（`data/quests.json`，正式獎勵欄位：`xp_reward`，含 `category`）
- Quest board loop：選任務 → 接任務 → 回報完成 → ParentGateOverlay PIN 驗證 → 發放 XP
- **P2-001 完成**：`ParentGateOverlay`（`scenes/parent_gate_overlay.tscn` + `scripts/parent_gate_overlay.gd`）
  - 預設測試 PIN：`1234`（`@export var parent_pin`）
  - `verified` signal → XP 發放；`cancelled` signal → 還原按鈕狀態
- 6 個 XP-gated 裝飾（`data/decorations.json`，正式解鎖欄位：`unlock_xp`）
  - 包含 `guild_planter`（70 XP）與 `wooden_shelf`（85 XP）Kenney 第一波 target path
- Queued decoration unlock overlay（一次只顯示一個）+ `play_unlock_pop()` scale-pop 動畫
- `SoundManager` autoload：programmatic 8-bit 音效佔位符
- `World/FloorTileMapLayer`（GridWorld）：16×16 checker 地板 + XP-reactive `floor_color` tween
- `HeroActor`：walk、face、interact（走近 QuestBoardObject 按 Space/Enter）
- Hero evolution scaffold（3 個進化階段，`data/hero_evolution.json`）

---

## 開場操作流程

```
python3 tools/verify_current_state.py
python3 tools/validate_asset_ledger.py
```

通過後再閱讀 `docs/current-state.md`，然後開始任務。

---

## 分支

開發分支：`claude/adoring-bell-dv270`
所有 commit 推送到此分支。

---

## 檔案速查

| 路徑 | 用途 |
|------|------|
| `scenes/guild_hall.tscn` | 主場景 |
| `scenes/hero_actor.tscn` | 角色場景 |
| `scenes/parent_gate_overlay.tscn` | 家長 PIN 確認 overlay（layer=8） |
| `scripts/guild_hall.gd` | 核心邏輯 |
| `scripts/hero_actor.gd` | 角色移動與互動 |
| `scripts/parent_gate_overlay.gd` | PIN gate（class_name ParentGateOverlay） |
| `scripts/grid_world.gd` | TileMapLayer 延伸，floor_color |
| `scripts/decor_placeholder.gd` | 裝飾渲染 + play_unlock_pop() |
| `scripts/quest_board_object.gd` | 互動告示板 |
| `scripts/sound_manager.gd` | Autoload SFX |
| `data/quests.json` | 6 張任務卡（xp_reward, category） |
| `data/decorations.json` | XP-gated 裝飾（unlock_xp, name） |
| `data/hero_evolution.json` | 3 個進化階段 |
| `tools/verify_current_state.py` | Baseline 完整性檢查 |
| `tools/validate_asset_ledger.py` | Kenney 素材授權檢查 |
| `tools/verify_first_wave_pngs.py` | PNG header 驗證（手動匯入後執行） |

---

## Do Not Regress

- `World/FloorTileMapLayer` 必須存在並可 tween `floor_color`
- `World/YSortLayer` 必須存在且 `y_sort_enabled = true`
- `HeroActor` 必須可走路並與 QuestBoardObject 互動
- Decoration unlock queue 必須保持（一次只顯示一個 overlay）
- `SoundManager.play_unlock_decor_sound()` 必須可呼叫
- `ParentGateOverlay` 必須以 PIN 驗證 gate XP 發放
- `data/quests.json` 使用 `xp_reward` 作為正式獎勵欄位
- `data/decorations.json` 使用 `unlock_xp` 作為解鎖門檻欄位

---

## Phase 2：家長確認 gate 及後續待辦（P2-001 已完成）

| 票號 | 項目 | 狀態 |
|------|------|------|
| P2-001 | 家長 PIN 確認 gate | ✅ 完成 |
| P2-002 | 真實 Kenney SFX 素材 + 裝飾 sprites | 待辦 |
| P2-003 | 動態英雄 sprite sheet | 待辦 |
| P2-004 | 本地存檔持久化 | 待辦 |
| P2-005 | 解鎖粒子特效 | 待辦 |
