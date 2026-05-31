# Asset License Ledger

This file documents all third-party assets used in Sweet Home OS and their license status.

## Kenney 1-Bit Pack

- **License**: CC0 1.0 Universal
- **Source**: kenney.nl/assets/1-bit-pack
- **Status**: Not yet imported (placeholder fallbacks active)
- **Staging directory**: `assets/kenney/1-bit-pack/`
- **Import instructions**: See `docs/phase-4.1-first-import-brief.md`

## Kenney Tiny Dungeon

- **License**: CC0 1.0 Universal
- **Source**: kenney.nl/assets/tiny-dungeon
- **Status**: Not yet imported (placeholder fallbacks active)
- **Staging directory**: `assets/kenney/tiny-dungeon/`

## Import Rules

- Do not commit ZIP files to the repository.
- Each imported package must have a `source.txt` file in its directory.
- Use `source.example.txt` as the template for `source.txt`.
- Run `python3 tools/validate_asset_ledger.py` after any import.
