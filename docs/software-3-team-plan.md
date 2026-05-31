# Sweet Home OS — Software-3 Team Plan

## Project Overview

**Sweet Home OS** is a family chore management system styled as a JRPG guild quest board.
Kids play as adventurers who accept household chore quests. Parents confirm completion; the
character earns XP and unlocks decorations. No punishment mechanics, no failure screens, no
member comparisons.

**Engine:** Godot 4.3  
**Resolution:** 1280 × 720 (canvas_items stretch)  
**Visual Style:** 2D JRPG  
**Language:** GDScript

---

## Division of Labor

| Member | Area |
|--------|------|
| A | Scene layout, UI/UX (guild_hall.tscn, XP label, detail panel) |
| B | Game logic (guild_hall.gd, quest state machine, save/load) |
| C | Character system (hero_actor.gd, hero_evolution.json, evolution stages) |
| D | Decoration system (decor_placeholder.gd, decorations.json, unlock animations) |
| E | Audio & polish (sound_manager.gd, SFX integration, background gradient) |
| F | Data & tooling (quests.json, validate_asset_ledger.py, verify_current_state.py) |

---

## Phase Tickets

### Phase 1 — Core Loop (current)
- **P1-001** Project scaffold: project.godot, scenes, scripts, data files
- **P1-002** Quest board: load quests.json, display buttons, detail panel
- **P1-003** XP system: award XP on completion, persist via save_data.json
- **P1-004** Decoration unlock queue: threshold check, UnlockOverlay animation
- **P1-005** HeroActor scaffold: evolution stages, sprite tint fallback
- **P1-006** SoundManager autoload: programmatic beep SFX placeholder
- **P1-007** Asset license ledger + validation tooling

### Phase 2 — Parent Confirmation & Polish
- **P2-001** PIN verification UI for parent confirmation of quest completion
- **P2-002** Replace programmatic beeps with Kenney CC0 audio assets
- **P2-003** Animated sprite sheets for hero evolution stages
- **P2-004** Particle effect on decoration unlock
- **P2-005** Quest category filter/sort in the quest list
- **P2-006** Settings screen (family name, PIN change)

### Phase 3 — Expansion
- **P3-001** Multiple hero profiles (one per child)
- **P3-002** Custom quest creation by parents
- **P3-003** Weekly quest streaks and bonus XP
- **P3-004** Export / print quest completion certificate

---

## Design Guardrails

1. **No punishment mechanics** — XP is never deducted. There are no failure screens.
2. **No member comparisons** — Individual XP and progress is never shown side-by-side.
3. **Positive reinforcement only** — Unlock messages use celebratory language.
4. **Parent gating** — All completion confirmations require parent action (Phase 2: PIN).
5. **Offline first** — All data stored locally via `user://save_data.json`.

---

## Data Contracts

### quests.json
```json
{
  "id": "string (snake_case)",
  "title": "string (zh-TW)",
  "description": "string (zh-TW)",
  "xp_reward": "int > 0",
  "category": "string",
  "difficulty": "int 1-3"
}
```

### decorations.json
```json
{
  "id": "string (snake_case)",
  "name": "string (zh-TW)",
  "unlock_xp": "int >= 0",
  "sprite_path": "string (relative to res://)",
  "description": "string (zh-TW)"
}
```

### hero_evolution.json
```json
{
  "stage": "int",
  "name": "string (zh-TW)",
  "min_xp": "int",
  "max_xp": "int",
  "sprite": "string (relative to res://)"
}
```
