# Phase 1 Brief — Sweet Home OS

## Goal

Deliver a playable core loop where a child can:
1. Open the app and see a list of household chore quests on the Guild Board.
2. Accept a quest (sets status to "進行中").
3. Complete the quest (parent confirms; TODO: PIN in Phase 2).
4. Earn XP and see the total update.
5. Unlock decorations when XP crosses defined thresholds.

---

## Core Loop

```
[Quest List] → select quest → [Detail Panel]
    → "接受任務" → quest state = accepted
    → "完成任務 ✓" → XP awarded → _check_decoration_unlocks()
        → if threshold crossed → UnlockOverlay shown → SFX played
    → HeroActor.setup_evolution(total_xp) → sprite/label updated
    → save_data.json written
```

---

## Data Contract (Phase 1)

All JSON files live under `res://data/`. No remote API calls. Save data written to
`user://save_data.json` via Godot's `FileAccess`.

| File | Purpose |
|------|---------|
| `data/quests.json` | 6 household chore quest cards |
| `data/decorations.json` | 5 decorations with XP unlock thresholds |
| `data/hero_evolution.json` | 3 hero evolution stages |

---

## Guardrails (Phase 1)

- XP is **never deducted**. `_total_xp` only increases.
- No failure state, no error screen shown to the child.
- Decoration unlock queue processes one item at a time to avoid UI overlap.
- `_unlocked_decor_ids` prevents double-unlock on save reload.
- Starter decoration (unlock_xp = 0) is awarded on first run via `_check_decoration_unlocks(_total_xp, -1)`.

---

## Out of Scope (Phase 1)

- PIN verification for parent confirmation → **P2-001**
- Real audio assets → **P2-002**
- Animated hero sprites → **P2-003**
- Multiple hero profiles → **P3-001**

---

## Acceptance Criteria

- [ ] App launches without errors in Godot 4.3
- [ ] All 6 quests display in the left panel
- [ ] Clicking a quest shows details in the right panel
- [ ] Accepting a quest changes its state label to "進行中"
- [ ] Completing a quest awards XP and updates the XP label
- [ ] Crossing a decoration XP threshold shows UnlockOverlay with correct name
- [ ] Data persists across app restarts (save/load round-trip)
- [ ] HeroActor label updates when XP crosses 1000 (stage 2)
- [ ] No Python validation errors in `tools/`
