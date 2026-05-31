#!/usr/bin/env python3
"""verify_current_state.py

Verifies that the Sweet Home OS repository contains all expected Phase 1 files
and that JSON data files are valid and well-formed.

Exit code 0 = all checks passed.
Exit code 1 = one or more checks failed.
"""

import json
import os
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ---------------------------------------------------------------------------
# Expected file manifest
# ---------------------------------------------------------------------------

REQUIRED_FILES: list[tuple[str, str]] = [
    # (relative path, description)
    ("project.godot",                          "Godot project config"),
    ("scenes/guild_hall.tscn",                 "Main guild hall scene"),
    ("scenes/hero_actor.tscn",                 "Hero actor scene"),
    ("scripts/guild_hall.gd",                  "Guild hall script"),
    ("scripts/hero_actor.gd",                  "Hero actor script"),
    ("scripts/decor_placeholder.gd",           "Decoration placeholder script"),
    ("scripts/sound_manager.gd",               "SoundManager autoload script"),
    ("data/quests.json",                        "Quest data"),
    ("data/decorations.json",                  "Decoration data"),
    ("data/hero_evolution.json",               "Hero evolution data"),
    ("docs/software-3-team-plan.md",           "Team plan design doc"),
    ("docs/phase-1-brief.md",                  "Phase 1 brief"),
    ("docs/current-state.md",                  "Current state record"),
    ("research/asset-license-ledger.md",       "Asset license ledger"),
    ("tools/validate_asset_ledger.py",         "Asset ledger validator"),
    ("tools/verify_current_state.py",          "State verifier (this file)"),
    ("assets/textures/icon.svg",               "Project icon"),
    (".gitignore",                              "Git ignore rules"),
]

# ---------------------------------------------------------------------------
# JSON schema spot-checks
# ---------------------------------------------------------------------------

JSON_CHECKS: list[dict] = [
    {
        "path": "data/quests.json",
        "is_array": True,
        "min_items": 6,
        "required_keys": ["id", "title", "description", "xp_reward", "category", "difficulty"],
    },
    {
        "path": "data/decorations.json",
        "is_array": True,
        "min_items": 5,
        "required_keys": ["id", "name", "unlock_xp", "sprite_path", "description"],
    },
    {
        "path": "data/hero_evolution.json",
        "is_array": True,
        "min_items": 3,
        "required_keys": ["stage", "name", "min_xp", "max_xp", "sprite"],
    },
]

# ---------------------------------------------------------------------------
# project.godot spot-checks
# ---------------------------------------------------------------------------

GODOT_REQUIRED_LINES: list[str] = [
    'config/name="Sweet Home OS"',
    'run/main_scene="res://scenes/guild_hall.tscn"',
    'SoundManager="*res://scripts/sound_manager.gd"',
    "window/size/viewport_width=1280",
    "window/size/viewport_height=720",
]

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

errors: list[str] = []


def check(condition: bool, ok_msg: str, fail_msg: str) -> None:
    if condition:
        print(f"[OK]   {ok_msg}")
    else:
        print(f"[FAIL] {fail_msg}")
        errors.append(fail_msg)


# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

def check_required_files() -> None:
    print("\n--- Required Files ---")
    for rel_path, description in REQUIRED_FILES:
        abs_path = os.path.join(REPO_ROOT, rel_path)
        exists = os.path.isfile(abs_path)
        check(exists, f"{rel_path}", f"MISSING: {rel_path} ({description})")


def check_json_files() -> None:
    print("\n--- JSON Validation ---")
    for spec in JSON_CHECKS:
        rel_path: str = spec["path"]
        abs_path = os.path.join(REPO_ROOT, rel_path)

        if not os.path.isfile(abs_path):
            msg = f"MISSING: {rel_path}"
            print(f"[FAIL] {msg}")
            errors.append(msg)
            continue

        with open(abs_path, encoding="utf-8") as f:
            try:
                data = json.load(f)
            except json.JSONDecodeError as e:
                msg = f"JSON parse error in {rel_path}: {e}"
                print(f"[FAIL] {msg}")
                errors.append(msg)
                continue

        # Array check
        if spec.get("is_array"):
            check(isinstance(data, list), f"{rel_path} is a JSON array",
                  f"{rel_path} should be a JSON array, got {type(data).__name__}")
            if isinstance(data, list):
                min_items: int = spec.get("min_items", 0)
                check(len(data) >= min_items,
                      f"{rel_path} has {len(data)} items (>= {min_items})",
                      f"{rel_path} has only {len(data)} items, expected >= {min_items}")

                # Key presence on first item
                req_keys: list[str] = spec.get("required_keys", [])
                if data and req_keys:
                    first = data[0]
                    missing_keys = [k for k in req_keys if k not in first]
                    check(not missing_keys,
                          f"{rel_path} first item has all required keys",
                          f"{rel_path} first item missing keys: {missing_keys}")


def check_godot_project() -> None:
    print("\n--- project.godot ---")
    godot_path = os.path.join(REPO_ROOT, "project.godot")
    if not os.path.isfile(godot_path):
        msg = "MISSING: project.godot"
        print(f"[FAIL] {msg}")
        errors.append(msg)
        return

    with open(godot_path, encoding="utf-8") as f:
        content = f.read()

    for line in GODOT_REQUIRED_LINES:
        check(line in content,
              f"project.godot contains: {line!r}",
              f"project.godot MISSING: {line!r}")


def check_decoration_xp_order() -> None:
    print("\n--- Decoration XP Ordering ---")
    abs_path = os.path.join(REPO_ROOT, "data", "decorations.json")
    if not os.path.isfile(abs_path):
        return
    with open(abs_path, encoding="utf-8") as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError:
            return  # Already reported above

    thresholds = [int(d.get("unlock_xp", 0)) for d in data]
    sorted_ok = thresholds == sorted(thresholds)
    check(sorted_ok,
          f"decorations.json XP thresholds are in ascending order: {thresholds}",
          f"decorations.json XP thresholds are NOT sorted: {thresholds}")

    has_zero = 0 in thresholds
    check(has_zero,
          "decorations.json has a starter decoration (unlock_xp = 0)",
          "decorations.json has no decoration with unlock_xp = 0 (starter item missing)")


def check_quest_count() -> None:
    print("\n--- Quest Count ---")
    abs_path = os.path.join(REPO_ROOT, "data", "quests.json")
    if not os.path.isfile(abs_path):
        return
    with open(abs_path, encoding="utf-8") as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError:
            return

    ids = [q.get("id") for q in data]
    unique_ids = set(ids)
    check(len(ids) == len(unique_ids),
          "All quest IDs are unique",
          f"Duplicate quest IDs found: {[i for i in ids if ids.count(i) > 1]}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    print("=== verify_current_state.py ===")

    check_required_files()
    check_json_files()
    check_godot_project()
    check_decoration_xp_order()
    check_quest_count()

    print()
    if errors:
        print(f"verify_current_state: {len(errors)} error(s) found.")
        return 1
    else:
        print("verify_current_state: all checks passed.")
        return 0


if __name__ == "__main__":
    sys.exit(main())
