#!/usr/bin/env python3
"""Verify that the advanced Sweet Home OS baseline is present."""

from __future__ import annotations

import json
from pathlib import Path
import sys
from typing import Any

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "README.md",
    "project.godot",
    "assets/icon.svg",
    "data/decorations.json",
    "data/hero_evolution.json",
    "data/quests.json",
    "scenes/guild_hall.tscn",
    "scenes/hero_actor.tscn",
    "scripts/decor_placeholder.gd",
    "scripts/guild_hall.gd",
    "scripts/hero_actor.gd",
    "scripts/sound_manager.gd",
    "scripts/quest_board_object.gd",
    "docs/design-plan.md",
    "docs/interaction-system.md",
    "docs/current-state.md",
    "docs/research/asset-license-ledger.md",
    "tools/validate_asset_ledger.py",
    ".gitignore",
    "assets/kenney/1-bit-pack/source.example.txt",
    "assets/kenney/tiny-dungeon/source.example.txt",
    "docs/phase-4.1-first-import-brief.md",
    "docs/new-session-brief.md",
]

REQUIRED_MARKERS = {
    "scripts/guild_hall.gd": [
        'const DECORATIONS_PATH := "res://data/decorations.json"',
        "var queued_unlocks: Array[Dictionary]",
        "func _on_quest_board_interacted() -> void:",
        "func _on_complete_pressed() -> void:",
        "func refresh_decorations(show_unlock_feedback := true) -> void:",
        "func _queue_decoration_unlock(decoration: Dictionary) -> void:",
        "background_tween.tween_property",
        "SoundManager.play_unlock_decor_sound()",
        "DecorPlaceholder.new()",
    ],
    "scripts/hero_actor.gd": [
        "func setup_evolution(p_total_xp: int) -> void:",
        "func _physics_process(delta: float) -> void:",
        "move_and_slide()",
        "func _update_procedural_motion(delta: float) -> void:",
        "func _try_interact() -> void:",
        "func _update_current_interactable() -> void:",
        "func _facing_vector() -> Vector2:",
    ],
    "scripts/decor_placeholder.gd": [
        "class_name DecorPlaceholder",
        "ResourceLoader.exists(sprite_path)",
        "fallback_shape",
        "func _draw_candle() -> void:",
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
        "QuestBoardObject",
    ],
    "scenes/hero_actor.tscn": [
        "InteractionArea",
        "InteractPrompt",
        "FallbackBody",
    ],
    "scripts/quest_board_object.gd": [
        "signal interacted",
        "func interact(_hero: Node = null) -> void:",
        "func get_interact_prompt() -> String:",
    ],
    "docs/interaction-system.md": [
        "InteractionArea",
        "QuestBoardObject",
        "ui_accept",
    ],
    "docs/design-plan.md": [
        "Warm autonomy",
        "Phase 1 Runtime Loop",
        "Phase 2 Candidate Tickets",
    ],
    "docs/phase-4.1-first-import-brief.md": [
        "assets/kenney/1-bit-pack/decor/candlestick.png",
        "source.example.txt",
        "Do not commit ZIP files",
    ],
    ".gitignore": [
        "__pycache__/",
        "*.zip",
        ".godot/",
    ],
    "docs/new-session-brief.md": [
        "Canonical branch: work",
        "docs/current-state.md",
        "python3 tools/verify_current_state.py",
        "Short Chinese Opening Prompt",
    ],
    "README.md": [
        "Canonical State",
        "queued decoration unlocks",
        "Do not reset it to a smaller Phase 1-only skeleton",
        "docs/design-plan.md",
    ],
}


def require_file(path: str) -> Path:
    full_path = ROOT / path
    if not full_path.is_file():
        raise AssertionError(f"missing required file: {path}")
    return full_path


def require_markers(path: str, markers: list[str]) -> None:
    full_path = require_file(path)
    text = full_path.read_text(encoding="utf-8")
    missing = [marker for marker in markers if marker not in text]
    if missing:
        raise AssertionError(f"{path} missing markers: {missing}")


def load_json_array(path: str) -> list[dict[str, Any]]:
    full_path = require_file(path)
    try:
        data = json.loads(full_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise AssertionError(f"{path} is invalid JSON: {error}") from error
    if not isinstance(data, list) or not all(isinstance(item, dict) for item in data):
        raise AssertionError(f"{path} must be a JSON array of objects")
    return data


def require_unique_ids(path: str, rows: list[dict[str, Any]]) -> None:
    ids = [row.get("id") for row in rows]
    if any(not isinstance(item_id, str) or not item_id for item_id in ids):
        raise AssertionError(f"{path} rows must all have non-empty string ids")
    if len(ids) != len(set(ids)):
        raise AssertionError(f"{path} contains duplicate ids")


def verify_data_logic() -> None:
    quests = load_json_array("data/quests.json")
    decorations = load_json_array("data/decorations.json")
    stages = load_json_array("data/hero_evolution.json")
    if len(quests) < 6:
        raise AssertionError("data/quests.json must contain at least six Phase 1 quests")
    if len(decorations) < 5:
        raise AssertionError("data/decorations.json must contain at least five decoration unlocks")
    if len(stages) < 3:
        raise AssertionError("data/hero_evolution.json must contain at least three hero stages")
    require_unique_ids("data/quests.json", quests)
    require_unique_ids("data/decorations.json", decorations)
    require_unique_ids("data/hero_evolution.json", stages)
    if min(int(row.get("required_total_xp", 999999)) for row in decorations) != 0:
        raise AssertionError("at least one decoration must be available at 0 XP")
    if min(int(row.get("required_total_xp", 999999)) for row in stages) != 0:
        raise AssertionError("at least one hero stage must be available at 0 XP")
    for quest in quests:
        if int(quest.get("xp_reward", 0)) <= 0:
            raise AssertionError(f"quest {quest.get('id')} must grant positive XP")
    for decoration in decorations:
        if "sprite_path" not in decoration or "shape" not in decoration:
            raise AssertionError(f"decoration {decoration.get('id')} needs sprite_path and fallback shape")


def main() -> int:
    try:
        for path in REQUIRED_FILES:
            require_file(path)
        for path, markers in REQUIRED_MARKERS.items():
            require_markers(path, markers)
        verify_data_logic()
    except AssertionError as error:
        print(f"current state check failed: {error}", file=sys.stderr)
        return 1
    print("current state checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
