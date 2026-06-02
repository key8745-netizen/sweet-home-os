#!/usr/bin/env python3
"""Validate guild hall blocker layout safety for the fallback grid world."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
HERO_SPAWN = (250.0, 300.0)
HERO_SAFE_RADIUS = 24.0
QUEST_BOARD_CENTER = (610.0, 210.0)
QUEST_BOARD_SIZE = (84.0, 60.0)
BOARD_PADDING = 12.0
HALL_BOUNDS = (32.0, 36.0, 768.0, 452.0)
WALL_GUIDE_RECTS = (
    (20.0, 28.0, 780.0, 44.0),
    (20.0, 444.0, 780.0, 460.0),
    (24.0, 30.0, 40.0, 450.0),
    (760.0, 30.0, 776.0, 450.0),
)
BOUNDARY_COLLISION_RECTS = WALL_GUIDE_RECTS


def rect_from_center(center: tuple[float, float], size: tuple[float, float]) -> tuple[float, float, float, float]:
    half_w = size[0] / 2.0
    half_h = size[1] / 2.0
    return (center[0] - half_w, center[1] - half_h, center[0] + half_w, center[1] + half_h)


def padded_rect(rect: tuple[float, float, float, float], padding: float) -> tuple[float, float, float, float]:
    return (rect[0] - padding, rect[1] - padding, rect[2] + padding, rect[3] + padding)


def rects_overlap(a: tuple[float, float, float, float], b: tuple[float, float, float, float]) -> bool:
    return a[0] < b[2] and a[2] > b[0] and a[1] < b[3] and a[3] > b[1]


def rects_match(a: tuple[float, float, float, float], b: tuple[float, float, float, float]) -> bool:
    return all(abs(a[index] - b[index]) <= 0.01 for index in range(4))


def load_decorations() -> list[dict[str, Any]]:
    data = json.loads((ROOT / "data/decorations.json").read_text(encoding="utf-8"))
    if not isinstance(data, list):
        raise AssertionError("data/decorations.json must be a list")
    return data


def decoration_blocker_rect(decoration: dict[str, Any]) -> tuple[float, float, float, float] | None:
    if not bool(decoration.get("blocks_movement", False)):
        return None
    position = decoration.get("scene_position", [])
    size = decoration.get("collision_size", [])
    offset = decoration.get("collision_offset", [0, 0])
    if not (isinstance(position, list) and len(position) == 2):
        raise AssertionError(f"blocking decoration {decoration.get('id')} needs scene_position [x, y]")
    if not (isinstance(size, list) and len(size) == 2):
        raise AssertionError(f"blocking decoration {decoration.get('id')} needs collision_size [width, height]")
    if not (isinstance(offset, list) and len(offset) == 2):
        raise AssertionError(f"blocking decoration {decoration.get('id')} needs collision_offset [x, y]")
    center = (float(position[0]) + float(offset[0]), float(position[1]) + float(offset[1]))
    return rect_from_center(center, (float(size[0]), float(size[1])))


def validate_wall_guides() -> None:
    if len(WALL_GUIDE_RECTS) != 4:
        raise AssertionError("expected four WallTileMapLayer guide rectangles")
    for index, (wall_rect, boundary_rect) in enumerate(zip(WALL_GUIDE_RECTS, BOUNDARY_COLLISION_RECTS, strict=True)):
        if not rects_match(wall_rect, boundary_rect):
            raise AssertionError(f"wall guide rectangle {index} does not align with its boundary collision shape")


def main() -> int:
    validate_wall_guides()
    hero_safe_rect = rect_from_center(HERO_SPAWN, (HERO_SAFE_RADIUS * 2.0, HERO_SAFE_RADIUS * 2.0))
    board_safe_rect = padded_rect(rect_from_center(QUEST_BOARD_CENTER, QUEST_BOARD_SIZE), BOARD_PADDING)
    hall_rect = HALL_BOUNDS
    blocker_count = 0
    for decoration in load_decorations():
        rect = decoration_blocker_rect(decoration)
        if rect is None:
            continue
        blocker_count += 1
        decoration_id = decoration.get("id", "<unknown>")
        if rects_overlap(rect, hero_safe_rect):
            raise AssertionError(f"blocking decoration {decoration_id} overlaps the hero spawn safe zone")
        if rects_overlap(rect, board_safe_rect):
            raise AssertionError(f"blocking decoration {decoration_id} overlaps the quest board access zone")
        if rect[0] < hall_rect[0] or rect[1] < hall_rect[1] or rect[2] > hall_rect[2] or rect[3] > hall_rect[3]:
            raise AssertionError(f"blocking decoration {decoration_id} is outside the hall boundary collision box")
    if blocker_count < 2:
        raise AssertionError("expected at least two data-driven decoration blockers")
    print("layout safety checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
