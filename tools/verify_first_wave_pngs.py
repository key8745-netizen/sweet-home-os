#!/usr/bin/env python3
"""verify_first_wave_pngs.py

Optional readiness check: confirms that the first-wave Kenney PNG files are
present and valid before attempting a Godot headless smoke test.

Exit code 0 = PNGs are in place and valid.
Exit code 1 = one or more PNGs are missing or corrupt (expected until manual import).
"""

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

FIRST_WAVE = [
    "assets/kenney/1-bit-pack/decor/guild_planter.png",
    "assets/kenney/1-bit-pack/decor/wooden_shelf.png",
]

PNG_HEADER = b"\x89PNG\r\n\x1a\n"


def validate_png(path: Path) -> list[str]:
    """Return a list of error strings for the given PNG path, or [] if valid."""
    errors: list[str] = []
    if not path.is_file():
        errors.append(f"missing file: {path.relative_to(ROOT)}")
        return errors
    try:
        header = path.read_bytes()[:8]
    except OSError as exc:
        errors.append(f"cannot read {path.relative_to(ROOT)}: {exc}")
        return errors
    if header != PNG_HEADER:
        errors.append(f"{path.relative_to(ROOT)} does not have a valid PNG header")
    return errors


def main() -> int:
    all_errors: list[str] = []
    for rel in FIRST_WAVE:
        all_errors.extend(validate_png(ROOT / rel))

    if all_errors:
        print("first-wave Kenney PNG check failed:")
        for err in all_errors:
            print(f"  - {err}; copy one approved Kenney 1-Bit Pack sprite here before running this check")
        print()
        print("Expected manual import flow:")
        print("1. Download Kenney 1-Bit Pack outside this repository.")
        print("2. Copy only guild_planter.png and wooden_shelf.png into assets/kenney/1-bit-pack/decor/.")
        print("3. Apply Godot pixel-art import settings: Nearest, mipmaps off, disabled/lossless compression.")
        return 1
    print("first-wave Kenney PNG checks passed — ready for Godot import smoke test.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
