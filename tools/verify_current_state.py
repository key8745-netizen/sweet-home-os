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
    "assets/textures/icon.svg",
    "assets/kenney/README.md",
    "assets/kenney/import_presets.md",
    "assets/kenney/1-bit-pack/source.txt",
    "assets/kenney/1-bit-pack/decor/.gitkeep",
    "data/decorations.json",
    "data/hero_evolution.json",
    "data/quests.json",
    "scenes/guild_hall.tscn",
    "scenes/hero_actor.tscn",
    "scenes/parent_gate_overlay.tscn",
    "scripts/decor_placeholder.gd",
    "scripts/parent_gate_overlay.gd",
    "scripts/grid_world.gd",
    "scripts/guild_hall.gd",
    "scripts/hero_actor.gd",
    "scripts/sound_manager.gd",
    "scripts/quest_board_object.gd",
    "docs/design-plan.md",
    "docs/interaction-system.md",
    "docs/current-state.md",
    "docs/research/asset-license-ledger.md",
    "tools/validate_asset_ledger.py",
    "tools/verify_first_wave_pngs.py",
    "tools/godot_smoke_test.py",
    ".gitignore",
    "assets/kenney/1-bit-pack/source.example.txt",
    "assets/kenney/tiny-dungeon/source.example.txt",
    "docs/phase-4.1-first-import-brief.md",
    "docs/phase-4.4-grid-world.md",
    "docs/new-session-brief.md",
    "docs/open-new-conversation.md",
]

REQUIRED_MARKERS = {
    "scripts/guild_hall.gd": [
        'const DECORATIONS_PATH := "res://data/decorations.json"',
        "var queued_unlocks: Array[Dictionary]",
        "func _on_quest_board_interacted() -> void:",
        "func _on_complete_pressed() -> void:",
        "func _quest_reward(quest: Dictionary) -> int:",
        "func refresh_decorations(show_unlock_feedback := true) -> void:",
        "func _queue_decoration_unlock(decoration: Dictionary) -> void:",
        "background_tween.tween_property",
        "floor_color",
        "$World/YSortLayer",
        "DECORATION_GROUP",
        "SoundManager.play_unlock_decor_sound()",
        "DecorPlaceholder.new()",
        "decoration_node.play_unlock_pop()",
        "func _on_parent_gate_verified() -> void:",
        "parent_gate_overlay.show_gate",
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
        "func _draw_shelf() -> void:",
    ],
    "scripts/grid_world.gd": [
        "extends TileMapLayer",
        "class_name GridWorld",
        "tile_size_px := 16",
        "func _draw_checker_tiles() -> void:",
        "func _draw_grid_lines(world_size: Vector2) -> void:",
    ],
    "scripts/sound_manager.gd": [
        "func play_unlock_decor_sound() -> void:",
        "AudioStreamWAV",
    ],
    "scenes/guild_hall.tscn": [
        "World",
        "FloorTileMapLayer",
        "TileMapLayer",
        "YSortLayer",
        "y_sort_enabled = true",
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
    "scenes/parent_gate_overlay.tscn": [
        "ParentGateOverlay",
        "QuestContextLabel",
        "PinInput",
        "ConfirmButton",
        "CancelButton",
    ],
    "scripts/parent_gate_overlay.gd": [
        "class_name ParentGateOverlay",
        "signal verified",
        "signal cancelled",
        'func show_gate(quest_title: String = "Quest", xp_reward: int = 0) -> void:',
        "@export var parent_pin",
        "func _show_error_feedback() -> void:",
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
    "docs/phase-4.4-grid-world.md": [
        "TileMapLayer",
        "World/YSortLayer",
        "floor_color",
    ],
    "docs/phase-4.1-first-import-brief.md": [
        "Manual Build Steps",
        "Queued Evolution Moment Checklist",
        "assets/kenney/1-bit-pack/decor/guild_planter.png",
        "assets/kenney/1-bit-pack/decor/wooden_shelf.png",
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
    "docs/open-new-conversation.md": [
        "Sweet Home OS 新對話接手提示",
        "Phase 2：家長確認 gate",
        "World/FloorTileMapLayer",
        "python3 tools/verify_current_state.py",
    ],
    "project.godot": [
        'renderer/rendering_method="gl_compatibility"',
        "ui_left",
        "ui_right",
        "ui_up",
        "ui_down",
    ],
    "assets/kenney/README.md": [
        "Manual Import Checklist",
        "guild_planter.png",
        "wooden_shelf.png",
        "res://assets/kenney/",
        "Do not commit ZIP files",
    ],
    "assets/kenney/import_presets.md": [
        "Nearest",
        "Mipmaps",
        "Compression",
        "divisible by 16",
    ],
    "assets/kenney/1-bit-pack/source.txt": [
        "Kenney 1-Bit Pack",
        "https://kenney.nl/assets/1-bit-pack",
        "CC0 1.0 Universal",
    ],
    "tools/verify_first_wave_pngs.py": [
        "def validate_png(path: Path) -> list[str]:",
        "first-wave Kenney PNG checks passed",
        "guild_planter.png",
        "wooden_shelf.png",
    ],
    "tools/godot_smoke_test.py": [
        "--require-godot",
        "godot binary not found; skipping optional headless smoke test",
        "--headless",
    ],
    "README.md": [
        "Canonical State",
        "queued decoration unlocks",
        "Do not reset it to a smaller Phase 1-only skeleton",
        "docs/design-plan.md",
        "TileMapLayer",
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
    if len(decorations) < 6:
        raise AssertionError("data/decorations.json must contain at least six decoration unlocks")
    if len(stages) < 3:
        raise AssertionError("data/hero_evolution.json must contain at least three hero stages")
    require_unique_ids("data/quests.json", quests)
    require_unique_ids("data/decorations.json", decorations)
    require_unique_ids("data/hero_evolution.json", stages)
    if min(int(row.get("unlock_xp", row.get("required_total_xp", 999999))) for row in decorations) != 0:
        raise AssertionError("at least one decoration must be available at 0 XP")
    if min(int(row.get("required_total_xp", 999999)) for row in stages) != 0:
        raise AssertionError("at least one hero stage must be available at 0 XP")
    for quest in quests:
        reward = int(quest.get("xp_reward", quest.get("reward_exp", 0)))
        if reward <= 0:
            raise AssertionError(f"quest {quest.get('id')} must grant positive EXP/XP")
        if "xp_reward" not in quest:
            raise AssertionError(f"quest {quest.get('id')} must use xp_reward as the canonical field")
        if "category" not in quest:
            raise AssertionError(f"quest {quest.get('id')} must include a category")
    for decoration in decorations:
        required_fields = ["name", "unlock_xp", "description", "sprite_path", "shape"]
        missing = [f for f in required_fields if f not in decoration]
        if missing:
            raise AssertionError(f"decoration {decoration.get('id')} missing fields: {missing}")
        sprite_path = str(decoration.get("sprite_path", ""))
        if sprite_path and not sprite_path.startswith("res://assets/kenney/"):
            raise AssertionError(f"decoration {decoration.get('id')} has non-project Kenney sprite_path: {sprite_path}")
    decoration_ids = {str(row.get("id")) for row in decorations}
    for required_id in ["guild_planter", "wooden_shelf"]:
        if required_id not in decoration_ids:
            raise AssertionError(f"missing first-wave decoration id: {required_id}")


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
