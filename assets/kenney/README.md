# Kenney Assets

This directory contains CC0-licensed assets from kenney.nl.

## Manual Import Checklist

Before committing any PNG from a Kenney pack:

- [ ] Download ZIP from kenney.nl — do **not** commit it.
- [ ] Extract locally, outside the repo.
- [ ] Copy only the required PNGs to `res://assets/kenney/`.
- [ ] Confirm sprite dimensions are divisible by 16.
- [ ] Apply Godot import settings from `assets/kenney/import_presets.md`.
- [ ] Copy `source.example.txt` → `source.txt` and fill in date and your name.
- [ ] Run `python3 tools/validate_asset_ledger.py`.

## Assets Used

- `guild_planter.png` — Guild Planter decoration (from 1-Bit Pack)
- `wooden_shelf.png` — Wooden Shelf decoration (from 1-Bit Pack)

All sprite paths reference `res://assets/kenney/` as the root.

## Rules

- Do not commit ZIP files to the repository.
- Each package must have a `source.txt` when PNGs are present.
- Use `source.example.txt` as the template.

See `docs/phase-4.1-first-import-brief.md` for the full import workflow.
