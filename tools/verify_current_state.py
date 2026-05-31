#!/usr/bin/env python3
"""Verify that the current advanced Sweet Home OS baseline is present.

This catches accidental regressions to an older minimal Phase 1 skeleton that
lacks XP, decorations, hero evolution, SFX, or asset-governance tooling.
"""

from pathlib import Path

REQUIRED_FILES = [
    "data/decorations.json",
    "data/hero_evolution.json",
    "scripts/decor_placeholder.gd",
    "scripts/hero_actor.gd",
    "scripts/sound_manager.gd",
    "docs/current-state.md",
    "docs/research/asset-license-ledger.md",
    "tools/validate_asset_ledger.py",
]

REQUIRED_MARKERS = {
    "scripts/guild_hall.gd": [
        'const DECORATIONS_PATH := "res://data/decorations.json"',
        "var queued_unlocks: Array[Dictionary]",
        "func _on_complete_pressed() -> void:",
        "func refresh_decorations(show_unlock_feedback := true) -> void:",
        "func _queue_decoration_unlock(decoration: Dictionary) -> void:",
        "background_tween.tween_property",
    ],
    "scripts/hero_actor.gd": [
        "func setup_evolution(p_total_xp: int) -> void:",
        "func _physics_process(delta: float) -> void:",
        "move_and_slide()",
        "func _update_procedural_motion(delta: float) -> void:",
    ],
    "scripts/sound_manager.gd": [
        "func play_unlock_decor_sound() -> void:",
        "AudioStreamWAV",
    ],
    "scenes/guild_hall.tscn": [
        "HeroActor",
        "CompleteButton",
        "UnlockPanel",
        "UnlockTimer",
        "Boundaries",
    ],
    "README.md": [
        "Canonical State",
        "queued decoration unlocks",
        "Do not reset it to a smaller Phase 1-only skeleton",
    ],
}


def require_file(path: str) -> None:
    if not Path(path).exists():
        raise SystemExit(f"Missing required advanced-baseline file: {path}")


def require_markers(path: str, markers: list[str]) -> None:
    require_file(path)
    text = Path(path).read_text(encoding="utf-8")
    missing = [marker for marker in markers if marker not in text]
    if missing:
        raise SystemExit(f"{path} is missing required advanced-baseline markers: {missing}")


def main() -> None:
    for path in REQUIRED_FILES:
        require_file(path)

    for path, markers in REQUIRED_MARKERS.items():
        require_markers(path, markers)

    print("current state checks passed")


if __name__ == "__main__":
    main()
