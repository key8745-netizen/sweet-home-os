# Sweet Home OS — 設計文件

## 專案概述

Sweet Home OS 是用 Godot 4.x 製作的家務管理系統，外觀借鏡傳統 2D JRPG。
小孩扮演冒險者從「家庭公會告示板」接取現實家務任務，完成後由家長確認，角色獲得 XP 與稱號成長。

## 分工原則

| 角色 | 負責範疇 |
|------|---------|
| Claude | Godot 工程實作 |
| Gemini | 教育原則、任務內容設計 |
| Grok | JRPG 趣味性、敘事語調 |

**Claude 不設計**：主角、NPC、怪物造型、Logo、最終像素風格。

## Canonical 起點（Phase 1 rebuild）

本 repo 目前視為 **clean Phase 1 rebuild**，以下為初始骨架：

- `project.godot`
- `scenes/guild_hall.tscn`
- `scripts/guild_hall.gd`
- `data/quests.json`

## Phase 1 Acceptance Criteria

- [ ] 可在 Godot 4.3 編輯器開啟專案不報錯
- [ ] 點選任務可顯示詳情（描述、難度、XP、家長提示）
- [ ] 按「接受任務」後按鈕 disable、狀態列更新
- [ ] `data/quests.json` 有 ≥ 3 張任務卡

## Phase 1 不含功能（留給後續 Phase）

- 家長確認模式（PIN / 雙介面）
- 每日任務重置
- 持久化 XP / 成就系統
- 正式像素風素材
- 多成員切換

## Phase 2 Tickets（待開發）

1. 家長確認介面：輸入 PIN 後標記任務完成、發放 XP
2. 玩家角色面板：顯示 XP、等級、稱號
3. 每日任務重置邏輯
4. JSON 存檔（`user://sweet_home_save.json`）

## 設計 Guardrails

- 不加入懲罰機制（扣 XP、失敗畫面）
- 不拿不同成員比較
- 不顯示監控或「偷看模式」提示
