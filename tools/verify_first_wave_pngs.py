#!/usr/bin/env python3
"""verify_first_wave_pngs.py

Optional readiness check: confirms that the first-wave Kenney PNG files are
present before attempting a Godot headless smoke test.

Exit code 0 = PNGs are in place.
Exit code 1 = one or more PNGs are missing (expected until manual import).
"""

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

FIRST_WAVE = [
    "assets/kenney/1-bit-pack/decor/guild_planter.png",
    "assets/kenney/1-bit-pack/decor/wooden_shelf.png",
]


def main() -> int:
    missing = [p for p in FIRST_WAVE if not (ROOT / p).is_file()]
    if missing:
        print("first-wave Kenney PNG check failed:")
        for p in missing:
            print(f"  - missing {p}; copy one approved Kenney 1-Bit Pack sprite here before running this check")
        print()
        print("Expected manual import flow:")
        print("1. Download Kenney 1-Bit Pack outside this repository.")
        print("2. Copy only guild_planter.png and wooden_shelf.png into assets/kenney/1-bit-pack/decor/.")
        print("3. Apply Godot pixel-art import settings: Nearest, mipmaps off, disabled/lossless compression.")
        return 1
    print("first-wave Kenney PNGs present — ready for Godot import smoke test.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
