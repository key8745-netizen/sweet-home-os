# Phase 1 Brief

## Phase 1 核心 Loop

1. 孩子開啟遊戲 → 看到任務告示板
2. 選擇一項家務任務 → 查看說明與家長提示
3. 按「接受任務」→ 去完成實際家務
4. 完成後告知家長 → 家長確認（Phase 2 功能）

## data/quests.json Data Contract

```json
{
  "id": "string (q001...)",
  "title": "string",
  "area": "string",
  "difficulty": "int 1-3",
  "estimated_minutes": "int",
  "xp_reward": "int",
  "description": "string",
  "parent_tip": "string"
}
```

## 設計 Guardrails

- **不懲罰**：沒有扣 XP、失敗畫面、倒數計時壓力
- **不比較**：不顯示兄弟姊妹排名
- **不監控**：不記錄完成時間用於評判
- **正向回饋**：完成訊息使用溫暖語調
