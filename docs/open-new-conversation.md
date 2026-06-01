# Sweet Home OS 新對話接手提示

このファイルを新しい AI セッションの冒頭プロンプトとして使用してください。

---

## 現況サマリー（日本語）

Sweet Home OS は Godot 4.3+ の家庭友善家務系統，用 2D JRPG 公會大廳風格製作。

この repo 已包含：

- 6 張中文 JRPG-style 任務卡，資料來自 `data/quests.json`，正式獎勵欄位是 `xp_reward`。
- Quest board loop：選任務、接任務、回報完成、增加 local `total_xp`。
- `data/decorations.json` 的 6 個 XP-gated decorations，包含 `guild_planter` 與 `wooden_shelf` 第一波 Kenney target path。
- Queued decoration unlock overlay，一次只顯示一個解鎖提示。
- `SoundManager` autoload：programmatic 8-bit 音效佔位符。
- `World/FloorTileMapLayer`（GridWorld）：16×16 checker 地板 + XP-reactive floor_color tween。
- HeroActor：walk、face、interact（走近 QuestBoardObject 按 Space/Enter）。
- Hero evolution scaffold（3 個進化階段）。

---

## Phase 2：家長確認 gate（下一步）

P2-001：CompleteButton → PIN 輸入 Dialog → 驗證 → 發放 XP。

---

## 開場操作流程

1. 執行 `python3 tools/verify_current_state.py`
2. 執行 `python3 tools/validate_asset_ledger.py`
3. 閱讀 `docs/current-state.md`
4. 開始任務

---

## 檔案速查

Runtime / Scene:

- `scenes/guild_hall.tscn` — 主場景（World/FloorTileMapLayer + World/YSortLayer）
- `scenes/hero_actor.tscn` — 角色場景（FallbackBody, InteractionArea, InteractPrompt）
- `scripts/guild_hall.gd` — 核心邏輯
- `scripts/hero_actor.gd` — 角色移動與互動
- `scripts/grid_world.gd` — TileMapLayer 延伸，floor_color
- `scripts/decor_placeholder.gd` — 裝飾渲染
- `scripts/quest_board_object.gd` — 互動告示板
- `scripts/sound_manager.gd` — Autoload SFX

Data:

- `data/quests.json` — 6 張中文 JRPG-style quest cards，使用 `xp_reward`。
- `data/decorations.json` — XP-gated decorations + Kenney first-wave target paths。
- `data/hero_evolution.json` — hero stage data。

---

## Do Not Regress

- `World/FloorTileMapLayer` 必須存在並可 tween `floor_color`
- `World/YSortLayer` 必須存在且 `y_sort_enabled = true`
- `HeroActor` 必須可以走路並與 QuestBoardObject 互動
- Decoration unlock queue 必須保持（一次只顯示一個 overlay）
- `SoundManager.play_unlock_decor_sound()` 必須可呼叫
- `data/quests.json` 使用 `xp_reward` 作為正式獎勵欄位
- `data/decorations.json` 使用 `unlock_xp` 作為解鎖門檻欄位
