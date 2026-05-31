# Phase 4.1 — First Asset Import Brief

This document describes how to import the first batch of Kenney CC0 assets.

## Assets to Import

| Asset | Source | Destination |
|-------|--------|-------------|
| `guild_planter.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/guild_planter.png` |
| `wooden_shelf.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/wooden_shelf.png` |
| `candlestick.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/candlestick.png` |
| `welcome_banner.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/welcome_banner.png` |
| `cozy_rug.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/cozy_rug.png` |
| `star_lantern.png` | Kenney 1-Bit Pack | `assets/kenney/1-bit-pack/decor/star_lantern.png` |

## Import Steps

1. Download the Kenney 1-Bit Pack ZIP from kenney.nl.
2. Do not commit ZIP files — extract locally.
3. Copy the required PNGs to the destinations above.
4. Copy `source.example.txt` to `source.txt` and fill in the import date.
5. Run `python3 tools/validate_asset_ledger.py` to confirm.
6. Open in Godot — sprites replace procedural fallbacks automatically.

## Guardrails

- Do not commit ZIP files to the repository.
- Do not import assets without a corresponding `source.txt`.
- Use `source.example.txt` as the template for `source.txt`.

The `assets/kenney/1-bit-pack/decor/guild_planter.png` and
`assets/kenney/1-bit-pack/decor/wooden_shelf.png` paths are referenced in
`data/decorations.json` as first-wave import targets.
