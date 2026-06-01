# Kenney Asset Import Presets for Godot 4.3

When importing Kenney 1-bit PNG assets into Godot, use these settings to preserve pixel-art quality.

## Texture Import Settings

Apply these in the Godot Import dock for each PNG:

| Setting | Value |
|---------|-------|
| Filter | **Nearest** (no filtering — preserves pixel edges) |
| Mipmaps | **Off** |
| Compression | **Disabled** or **Lossless** |
| Detect 3D | Off |

## Pixel-Art Rules

- Sprite dimensions must be **divisible by 16** (matches the grid tile size).
- Do not use Linear or Bilinear filtering — it blurs pixel art.
- Mipmaps degrade quality at small sizes; disable them.

## Validation Notes

`tools/validate_asset_ledger.py` checks `.png.import` sidecar files and will
reject imports with mipmaps enabled, filter enabled, or non-lossless compression.
It also parses PNG headers to confirm dimensions are divisible by 16.
