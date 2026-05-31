# Phase 4.1 — First Asset Import Brief

This document describes how to import the first batch of Kenney CC0 assets.

## Assets to Import

| Asset | Source | Destination |
|-------|--------|-------------|
| `candlestick.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/candlestick.png` |
| `welcome_banner.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/welcome_banner.png` |
| `cozy_rug.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/cozy_rug.png` |
| `guild_planter.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/guild_planter.png` |
| `star_lantern.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/star_lantern.png` |

## Import Steps

1. Download the Kenney 1-Bit Pack ZIP from kenney.nl.
2. Do not commit ZIP files — extract locally.
3. Copy the required PNGs to the destinations above.
4. Copy `source.example.txt` to `source.txt` in the package directory and fill in the import date and your name.
5. Run `python3 tools/validate_asset_ledger.py` to confirm.
6. Open in Godot — the sprites will automatically replace the procedural fallbacks.

## Guardrails

- Do not commit ZIP files to the repository.
- Do not import assets without a corresponding `source.txt`.
- Use `source.example.txt` as the template for `source.txt`.
- See `docs/research/asset-license-ledger.md` for license details.

The `assets/kenney/1-bit-pack/decor/candlestick.png` path is already referenced in `data/decorations.json` — importing the real file will automatically upgrade the in-game visual from the procedural placeholder.
