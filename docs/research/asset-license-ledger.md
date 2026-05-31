# Asset License Ledger

All external assets must be reviewed and logged here before being imported into the project.

## Status Legend

- `APPROVED` — license confirmed CC0 or equivalent; safe to import
- `PENDING` — under review
- `REJECTED` — incompatible license

## Kenney Assets (kenney.nl)

All Kenney packs are CC0 1.0 Universal. No attribution required, but appreciated.

| Pack | Status | Import Path | Notes |
|------|--------|-------------|-------|
| (none imported yet) | — | — | Phase 1 uses geometric placeholders only |

## Import Rules

1. Add a `source.txt` alongside any imported asset folder listing pack name, URL, and license.
2. Update this ledger before committing any asset file.
3. Do not import assets with NC (non-commercial) or ND (no-derivatives) clauses.

## Placeholder Policy

Until an asset is `APPROVED` and logged here, all visuals must use procedural placeholders (`ColorRect`, `Polygon2D`, or generated geometry). This ensures the project is always buildable without external downloads.
