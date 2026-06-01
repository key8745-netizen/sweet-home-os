# Original Sprite Art Handoff

This document describes guidelines for revising or creating the original pixel-art decoration sprites.

## Current First-Wave Sprites

- `assets/original/decor/guild_planter.png`
- `assets/original/decor/wooden_shelf.png`

## Acceptance Checklist

Before committing revised sprites:

- [ ] Dimensions divisible by 16 (16x16 or 32x32 preferred)
- [ ] Style: warm, cozy, family-friendly — no scary or violent imagery
- [ ] Color palette: earthy tones consistent with the guild hall mood
- [ ] Background: transparent (RGBA PNG) or solid matching the floor color
- [ ] `python3 tools/verify_first_wave_pngs.py` passes

## Rules

- Do not import external asset packs here.
- Keep Godot import settings: Nearest filtering, Mipmaps off, Lossless compression.
- Revisions must maintain the warm, non-punitive family tone.
