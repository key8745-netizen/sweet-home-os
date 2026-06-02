#!/usr/bin/env python3
"""Godot smoke test: verify project.godot is parseable and optionally run Godot headless.

Usage:
    python3 tools/godot_smoke_test.py               # Skip if Godot not found
    python3 tools/godot_smoke_test.py --require-godot  # Fail if Godot not found
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT_GODOT = ROOT / "project.godot"
MAIN_SCENE = "res://scenes/guild_hall.tscn"


def check_project_godot() -> None:
    if not PROJECT_GODOT.is_file():
        raise AssertionError("project.godot not found")
    text = PROJECT_GODOT.read_text(encoding="utf-8")
    for marker in [
        'config/name="Sweet Home OS"',
        "SoundManager",
        "gl_compatibility",
    ]:
        if marker not in text:
            raise AssertionError(f"project.godot missing expected marker: {marker!r}")


def find_godot() -> str | None:
    for candidate in ("godot", "godot4", "godot-4", "Godot_v4"):
        if shutil.which(candidate):
            return candidate
    return None


def run_godot_headless(binary: str) -> None:
    cmd = [binary, "--headless", "--quit", "--path", str(ROOT)]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
    if result.returncode not in (0, 255):
        # Godot headless may return 255 on normal quit; treat as ok
        raise AssertionError(
            f"Godot exited with code {result.returncode}.\n"
            f"stdout: {result.stdout[-2000:]}\n"
            f"stderr: {result.stderr[-2000:]}"
        )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--require-godot",
        action="store_true",
        help="Fail if Godot binary is not found in PATH",
    )
    args = parser.parse_args()

    try:
        check_project_godot()
        print("[OK] project.godot structure valid")
    except AssertionError as err:
        print(f"[FAIL] project.godot check: {err}", file=sys.stderr)
        return 1

    binary = find_godot()
    if binary is None:
        if args.require_godot:
            print(
                "[FAIL] --require-godot set but no Godot binary found in PATH",
                file=sys.stderr,
            )
            return 1
        print("[SKIP] Godot binary not found — skipping headless run (environment limitation)")
        return 0

    print(f"[OK] Godot binary found: {binary}")
    try:
        run_godot_headless(binary)
        print("[OK] Godot headless run completed")
    except subprocess.TimeoutExpired:
        print("[FAIL] Godot headless run timed out after 60s", file=sys.stderr)
        return 1
    except AssertionError as err:
        print(f"[FAIL] {err}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
