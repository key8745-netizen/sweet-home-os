#!/usr/bin/env python3
"""Optional Godot headless smoke test wrapper.

Usage:
    python3 tools/godot_smoke_test.py               # skips cleanly if godot is not installed
    python3 tools/godot_smoke_test.py --require-godot  # fails if godot binary is missing (for CI)
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    parser = argparse.ArgumentParser(description="Optional Godot headless smoke test")
    parser.add_argument(
        "--require-godot",
        action="store_true",
        help="Fail with exit code 1 if no godot binary is found (use in CI where Godot is expected)",
    )
    args = parser.parse_args()

    godot_bin = shutil.which("godot") or shutil.which("godot4")
    if godot_bin is None:
        if args.require_godot:
            print("ERROR: --require-godot set but no godot binary found in PATH", file=sys.stderr)
            sys.exit(1)
        print("godot binary not found; skipping optional headless smoke test")
        return

    print(f"Running headless smoke test with: {godot_bin}")
    result = subprocess.run(
        [godot_bin, "--headless", "--path", str(ROOT), "--quit"],
        capture_output=False,
    )
    if result.returncode != 0:
        print(f"Godot headless smoke test failed (exit {result.returncode})", file=sys.stderr)
        sys.exit(result.returncode)
    print("Godot headless smoke test passed")


if __name__ == "__main__":
    main()
