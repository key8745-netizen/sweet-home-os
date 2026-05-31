# Phase 4.1 — First Asset Import Brief

This document describes how to import the first batch of Kenney CC0 assets into the project.

## Assets to Import

| Asset | Source | Destination |
|-------|--------|-------------|
| `guild_planter.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/guild_planter.png` |
| `wooden_shelf.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/wooden_shelf.png` |
| `candlestick.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/candlestick.png` |
| `welcome_banner.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/welcome_banner.png` |
| `cozy_rug.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/cozy_rug.png` |
| `star_lantern.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/star_lantern.png` |

## Manual Build Steps

1. Download the Kenney 1-Bit Pack ZIP from kenney.nl — **do not commit the ZIP**.
2. Extract the ZIP locally, outside the repo directory.
3. Copy the required PNGs (listed above) to their destination paths.
4. Confirm each PNG's dimensions are divisible by 16 (required for the grid).
5. Open in Godot 4.3 and apply import settings from `assets/kenney/import_presets.md`.
6. Copy `source.example.txt` → `source.txt` in the package directory and fill in:
   - Import date
   - Your name
7. Run `python3 tools/validate_asset_ledger.py` — must pass before committing.
8. Commit with message: `feat(assets): import Kenney 1-bit-pack first wave (guild_planter, wooden_shelf)`

## Queued Evolution Moment Checklist

Test the unlock sequence after import:

- [ ] Start the game with 0 XP — only the Welcome Banner decoration is visible.
- [ ] Complete quests to reach 70 XP — Guild Planter should unlock and overlay appears.
- [ ] Continue to 85 XP — Wooden Shelf unlocks. Queue ensures overlays appear one at a time.
- [ ] Confirm the real PNG sprite replaces the procedural placeholder for each imported asset.
- [ ] Confirm that non-imported decorations still fall back to procedural shapes gracefully.

## Guardrails

- Do not commit ZIP files to the repository.
- Do not import assets without a corresponding `source.txt`.
- Use `source.example.txt` as the template for `source.txt`.
- See `docs/research/asset-license-ledger.md` for license details.

The `assets/kenney/1-bit-pack/decor/guild_planter.png` and
`assets/kenney/1-bit-pack/decor/wooden_shelf.png` paths are the first-wave
import targets referenced in `data/decorations.json`.
