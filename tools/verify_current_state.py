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
    "assets/original/README.md",
    "assets/original/decor/guild_planter.png",
    "assets/original/decor/wooden_shelf.png",
    "data/decorations.json",
    "data/hero_evolution.json",
    "data/quests.json",
    "scenes/guild_hall.tscn",
    "scenes/hero_actor.tscn",
    "scenes/parent_gate_overlay.tscn",
    "scripts/decor_placeholder.gd",
    "scripts/grid_world.gd",
    "scripts/guild_hall.gd",
    "scripts/hero_actor.gd",
    "scripts/sound_manager.gd",
    "scripts/save_manager.gd",
    "scripts/quest_board_object.gd",
    "scripts/parent_gate_overlay.gd",
    "docs/design-plan.md",
    "docs/interaction-system.md",
    "docs/current-state.md",
    "docs/research/asset-license-ledger.md",
    "tools/validate_asset_ledger.py",
    "tools/import_first_wave_kenney.py",
    "tools/verify_first_wave_pngs.py",
    "tools/verify_layout_safety.py",
    "tools/godot_smoke_test.py",
    "scripts/wall_tile_map_layer.gd",
    "scripts/collision_debug_overlay.gd",
    ".gitignore",
    "assets/kenney/1-bit-pack/source.example.txt",
    "assets/kenney/tiny-dungeon/source.example.txt",
    "docs/phase-4.1-first-import-brief.md",
    "docs/phase-4.4-grid-world.md",
    "docs/original-sprite-art-handoff.md",
    "docs/new-session-brief.md",
    "docs/open-new-conversation.md",
]

REQUIRED_MARKERS = {
    "scripts/guild_hall.gd": [
        'const DECORATIONS_PATH := "res://data/decorations.json"',
        'const HERO_STAGES_PATH := "res://data/hero_evolution.json"',
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
        "parent_gate_overlay.show_gate",
        "help_button.pressed.connect(_on_help_pressed)",
        "func _on_help_pressed() -> void:",
        "func _on_help_close_pressed() -> void:",
        "func _on_parent_gate_verified() -> void:",
        "func _update_hero_status_label() -> void:",
        "func _current_hero_stage() -> Dictionary:",
        "func _next_hero_stage() -> Dictionary:",
        "func _exit_tree() -> void:",
        "func _apply_save_data(save_data: Dictionary) -> void:",
        "func _save_progress() -> void:",
        "func _should_reset_daily_quest(save_data: Dictionary) -> bool:",
        "func _current_date_string() -> String:",
        "last_play_date",
        "autosave_timer.wait_time = 30.0",
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
        "func play_unlock_pop() -> void:",
    ],
    "scripts/grid_world.gd": [
        "extends TileMapLayer",
        "class_name GridWorld",
        "tile_size_px := 16",
        "func _draw_checker_tiles() -> void:",
        "func _draw_grid_lines(world_size: Vector2) -> void:",
    ],
    "scripts/wall_tile_map_layer.gd": [
        "class_name WallTileMapLayer",
        "top_wall_rect",
        "bottom_wall_rect",
        "left_wall_rect",
        "right_wall_rect",
        "func get_wall_rects() -> Array[Rect2]:",
        "func _draw_wall_band(rect: Rect2",
        "func _draw_tile_ticks(rect: Rect2",
    ],
    "scripts/collision_debug_overlay.gd": [
        "class_name CollisionDebugOverlay",
        "HALL_BOUNDS",
        "WALL_GUIDE_RECTS",
        "HERO_SPAWN",
        "QUEST_BOARD_CENTER",
        "func set_debug_visible(enabled: bool) -> void:",
        "func _decoration_blocker_rect(decoration: Dictionary) -> Rect2:",
        'Color("#c49a6c")',
    ],
    "scripts/sound_manager.gd": [
        "func play_unlock_decor_sound() -> void:",
        "AudioStreamWAV",
    ],
    "scripts/save_manager.gd": [
        "SAVE_PATH",
        "func save_game(",
        "func load_game(",
        "func reset_save(",
        "last_play_date",
    ],
    "scripts/parent_gate_overlay.gd": [
        "signal verified",
        "signal cancelled",
        "func show_gate() -> void:",
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
        "HeroStatusLabel",
        "Family Help",
    ],
    "scenes/hero_actor.tscn": [
        "InteractionArea",
        "InteractPrompt",
        "FallbackBody",
    ],
    "scenes/parent_gate_overlay.tscn": [
        "PinInput",
        "ConfirmButton",
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
        "tools/godot_smoke_test.py",
        "Hero Status HUD",
        "Sweet Home OS 新對話接手提示",
        "SaveManager",
        "Family Help",
    ],
    "project.godot": [
        'config/icon="res://assets/textures/icon.svg"',
        'renderer/rendering_method="gl_compatibility"',
        "ui_left",
        "ui_right",
        "ui_up",
        "ui_down",
        "SaveManager",
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
    "assets/original/README.md": [
        "guild_planter.png",
        "wooden_shelf.png",
        "divisible by 16",
    ],
    "tools/verify_first_wave_pngs.py": [
        "def validate_png(path: Path) -> list[str]:",
        "first-wave original PNG checks passed",
    ],
    "tools/godot_smoke_test.py": [
        "--require-godot",
        "godot binary not found; skipping optional headless smoke test",
        "--headless",
    ],
    "tools/verify_layout_safety.py": [
        "HERO_SPAWN",
        "QUEST_BOARD_CENTER",
        "layout safety checks passed",
        "blocking decoration",
        "WALL_GUIDE_RECTS",
        "BOUNDARY_COLLISION_RECTS",
        "def validate_wall_guides() -> None:",
    ],
    "README.md": [
        "tools/godot_smoke_test.py",
        "Hero Status HUD",
        "Canonical State",
        "queued decoration unlocks",
        "Do not reset it to a smaller Phase 1-only skeleton",
        "docs/design-plan.md",
        "TileMapLayer",
        "Family Help",
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
    unlock_xp_values = [int(row.get("unlock_xp", row.get("required_total_xp", 999999))) for row in decorations]
    if min(unlock_xp_values) != 0:
        raise AssertionError("at least one decoration must be available at 0 XP")
    if min(int(row.get("required_total_xp", row.get("min_xp", 999999))) for row in stages) != 0:
        raise AssertionError("at least one hero stage must be available at 0 XP")
    for quest in quests:
        reward = int(quest.get("xp_reward", quest.get("reward_exp", 0)))
        if reward <= 0:
            raise AssertionError(f"quest {quest.get('id')} must grant positive XP")
    for decoration in decorations:
        if "sprite_path" not in decoration or "shape" not in decoration:
            raise AssertionError(f"decoration {decoration.get('id')} needs sprite_path and fallback shape")
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
