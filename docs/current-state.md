# Current State — Sweet Home OS

**Date:** 2026-05-31  
**Branch:** `claude/pensive-tesla-5xCFu`  
**Phase:** 1 (scaffold complete)

---

## What Exists

### Project Configuration
- `project.godot` — Godot 4.3, 1280×720, SoundManager autoload configured

### Scenes
- `scenes/guild_hall.tscn` — main scene with Background, QuestList, DetailPanel, XPLabel,
  UnlockOverlay, HeroActor
- `scenes/hero_actor.tscn` — character actor with Sprite2D and StageLabel

### Scripts
- `scripts/guild_hall.gd` — full core loop: quest loading, XP, decoration unlock queue,
  background gradient, save/load
- `scripts/hero_actor.gd` — evolution scaffold: stage lookup, sprite tint fallback
- `scripts/decor_placeholder.gd` — decoration renderer: sprite_path priority, geometry fallback
- `scripts/sound_manager.gd` — autoload SFX: programmatic beep placeholders

### Data
- `data/quests.json` — 6 household chore quests (zh-TW titles)
- `data/decorations.json` — 5 decorations (unlock at 0/500/1500/3500/8000 XP)
- `data/hero_evolution.json` — 3 evolution stages (0/1000/5000 XP min)

### Assets
- `assets/textures/icon.svg` — placeholder SVG icon (guild shield with house)

### Tooling
- `tools/validate_asset_ledger.py` — validates research/asset-license-ledger.md and asset staging
- `tools/verify_current_state.py` — verifies repo file structure and JSON validity

### Documentation
- `docs/software-3-team-plan.md` — design doc, phase tickets, division of labor
- `docs/phase-1-brief.md` — phase 1 loop, data contract, guardrails, acceptance criteria
- `docs/current-state.md` — this file

### Research
- `research/asset-license-ledger.md` — Kenney CC0 asset license records

---

## What Is NOT Yet Done (Phase 2+)

- PIN verification for parent confirmation (P2-001)
- Real Kenney audio SFX assets (P2-002)
- Animated hero sprite sheets — `assets/hero/stage1-3.png` are referenced but not present (P2-003)
- Actual Kenney decoration sprites — `assets/kenney/` directory referenced but not staged (P2-002)
- Particle effects on unlock (P2-004)
- Multiple hero profiles (P3-001)

---

## Known Limitations

- `HeroActor` sprite loads gracefully fail (no texture = just tint change) until real assets land.
- `DecorPlaceholder` falls back to coloured geometry rectangles for all 5 decorations since
  Kenney assets are not yet staged.
- SFX are programmatic sine-wave beeps; no audio files referenced.
