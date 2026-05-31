# Asset License Ledger — Sweet Home OS

All third-party assets used in this project must be listed here before being committed to the
repository. Unlicensed or proprietary assets must not be staged.

---

## License Key

| Code | License | Commercial OK | Attribution Required |
|------|---------|--------------|---------------------|
| CC0  | Creative Commons Zero 1.0 Universal | Yes | No |
| CC-BY | Creative Commons Attribution | Yes | Yes |
| MIT  | MIT License | Yes | Yes (in notices) |

---

## Kenney Assets

**Publisher:** Kenney (https://kenney.nl)  
**License:** Creative Commons Zero 1.0 Universal (CC0)  
**Attribution:** Not required, but appreciated.  
**Source:** https://kenney.nl/assets

> All Kenney assets listed below are CC0. No per-file attribution is legally required,
> but the ledger is maintained for traceability.

### 1-Bit Pack
**Pack URL:** https://kenney.nl/assets/1-bit-pack  
**License:** CC0 1.0  
**Staging path:** `assets/kenney/1-bit-pack/`  
**Status:** NOT YET STAGED (Phase 2 task P2-002)

| Asset File | Used As | Unlock XP |
|-----------|---------|-----------|
| `decor/candlestick.png` | starter_banner + candle_stand sprites | 0, 500 |
| `decor/vines.png` | vine_wall sprite | 1500 |
| `decor/bookshelf.png` | bookshelf sprite | 3500 |
| `decor/hero_rug.png` | hero_rug sprite | 8000 |

### Music / SFX Pack (planned)
**Pack URL:** https://kenney.nl/assets/music-jingles  
**License:** CC0 1.0  
**Staging path:** `assets/kenney/sfx/`  
**Status:** NOT YET STAGED (Phase 2 task P2-002)

| Asset File | Used As |
|-----------|---------|
| TBD | play_unlock_decor_sound() |
| TBD | play_quest_accept_sound() |

---

## Project-Authored Assets

| File | Author | Notes |
|------|--------|-------|
| `assets/textures/icon.svg` | Claude Code (generated) | Original work, no third-party content |

---

## Staging Checklist (before committing any asset)

- [ ] Asset is listed in this ledger with pack URL and license code
- [ ] License is CC0 or equivalent permissive license
- [ ] Asset file is placed under the correct `assets/kenney/<pack-name>/` path
- [ ] `tools/validate_asset_ledger.py` passes without errors
