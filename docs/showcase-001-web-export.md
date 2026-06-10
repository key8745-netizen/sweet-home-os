# Showcase 001 — Manual Godot Web Export Guide

This is a **temporary, manual** process to get a playable build onto
Netlify so the public demo URL shows the actual Guild Hall scene
(including the Feature A audio toggle and volume slider).

The repo currently has no Godot binary in CI, so the `web-build/`
output must be produced locally and committed for now. This should be
replaced later by an automated CI export.

## Prerequisites

1. Install **Godot 4.3** (the engine version this project targets).
2. In Godot, install the **Web export templates** that match your
   editor version:
   - Editor menu → `Editor` → `Manage Export Templates...` → install
     the matching version if not already present.

## Steps

1. Open Godot and import this project (`project.godot` at the repo
   root).
2. Go to `Project` → `Export...`.
3. You should see a **Web** preset (provided by `export_presets.cfg`
   in this repo). If it's missing, click `Add...` → `Web` and set:
   - Export path: `web-build/index.html`
   - Thread Support: **off** (already set in `export_presets.cfg`)
4. Select the **Web** preset and click **Export Project**.
5. Confirm `web-build/` now contains:
   - `index.html`
   - `*.wasm`
   - `*.pck`
   - `*.js` (Godot's web runtime glue script)
6. From the repo root:
   ```bash
   git checkout showcase/001-web-demo
   git add export_presets.cfg netlify.toml web-build/
   git commit -m "chore: add Showcase 001 web export build"
   git push origin showcase/001-web-demo
   ```

## What to check after deploy

Once Netlify redeploys from `web-build/`, the public URL should show:

- The Guild Hall main scene (floor grid, hero, quest board)
- The Help panel, opened via the Help button, containing:
  - the **SFX** toggle (`SfxToggleButton`)
  - the **volume slider** (`SfxVolumeSlider`)

## Notes / limitations

- `web-build/` is committed as a temporary measure for this showcase.
  Once a CI pipeline with a Godot binary is available, prefer building
  `web-build/` automatically and excluding it from version control.
- This guide does not change any gameplay, save, or audio logic from
  Feature A.
