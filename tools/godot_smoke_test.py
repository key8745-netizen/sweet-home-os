#!/usr/bin/env python3
"""Optional Godot headless smoke test wrapper.

Runs `godot --headless --path <repo_root> --quit`.
Skips cleanly when no godot binary is found unless --require-godot is passed.
"""
from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--require-godot", action="store_true",
                        help="Fail if godot binary is not found (for CI use)")
    args = parser.parse_args()

    godot = shutil.which("godot") or shutil.which("godot4")
    if not godot:
        if args.require_godot:
            print("ERROR: godot binary not found; --require-godot was set", file=sys.stderr)
            return 1
        print("godot binary not found; skipping optional headless smoke test")
        return 0

    result = subprocess.run(
        [godot, "--headless", "--path", str(ROOT), "--quit"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(f"Godot smoke test failed (exit {result.returncode})", file=sys.stderr)
        print(result.stderr, file=sys.stderr)
        return 1
    print("Godot headless smoke test passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
