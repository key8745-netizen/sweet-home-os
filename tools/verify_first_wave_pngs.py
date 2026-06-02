#!/usr/bin/env python3
"""Check first-wave original PNG readiness for guild_planter.png and wooden_shelf.png."""
from __future__ import annotations

import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIRST_WAVE = [
    ROOT / "assets/original/decor/guild_planter.png",
    ROOT / "assets/original/decor/wooden_shelf.png",
]


def validate_png(path: Path) -> list[str]:
    errors: list[str] = []
    if not path.is_file():
        errors.append(f"missing: {path.relative_to(ROOT)}")
        return errors
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        errors.append(f"{path.name}: not a valid PNG file")
        return errors
    width = struct.unpack(">I", data[16:20])[0]
    height = struct.unpack(">I", data[20:24])[0]
    if width % 16 != 0 or height % 16 != 0:
        errors.append(f"{path.name}: dimensions {width}x{height} are not divisible by 16")
    return errors


def main() -> int:
    errors: list[str] = []
    for png_path in FIRST_WAVE:
        errors.extend(validate_png(png_path))
    if errors:
        for error in errors:
            print(f"FAIL: {error}", file=sys.stderr)
        return 1
    print("first-wave original PNG checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
