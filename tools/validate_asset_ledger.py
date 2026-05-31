#!/usr/bin/env python3
"""Validate asset-staging docs and guard against accidental ZIP commits."""

from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
LEDGER = ROOT / "docs/research/asset-license-ledger.md"
SOURCE_EXAMPLES = [
    ROOT / "assets/kenney/1-bit-pack/source.example.txt",
    ROOT / "assets/kenney/tiny-dungeon/source.example.txt",
]
REQUIRED_LEDGER_MARKERS = [
    "Kenney 1-Bit Pack",
    "Kenney Tiny Dungeon",
    "CC0 1.0 Universal",
    "Do not commit ZIP files",
    "source.txt",
]
REQUIRED_SOURCE_MARKERS = [
    "Package:",
    "Source URL:",
    "License: CC0 1.0 Universal",
    "Imported by:",
    "Import date:",
]


def fail(message: str) -> int:
    print(f"asset ledger check failed: {message}", file=sys.stderr)
    return 1


def read_text(path: Path) -> str:
    if not path.is_file():
        raise FileNotFoundError(path)
    return path.read_text(encoding="utf-8")


def main() -> int:
    try:
        ledger_text = read_text(LEDGER)
    except FileNotFoundError:
        return fail("missing docs/research/asset-license-ledger.md")
    for marker in REQUIRED_LEDGER_MARKERS:
        if marker not in ledger_text:
            return fail(f"ledger missing marker: {marker}")
    for path in SOURCE_EXAMPLES:
        try:
            text = read_text(path)
        except FileNotFoundError:
            return fail(f"missing source template: {path.relative_to(ROOT)}")
        for marker in REQUIRED_SOURCE_MARKERS:
            if marker not in text:
                return fail(f"{path.relative_to(ROOT)} missing marker: {marker}")
    zip_files = [path for path in ROOT.rglob("*.zip") if ".git" not in path.parts]
    if zip_files:
        return fail("ZIP files must not be committed: " + ", ".join(str(p.relative_to(ROOT)) for p in zip_files))
    imported_pngs = [path for path in (ROOT / "assets/kenney").rglob("*.png")]
    if imported_pngs:
        missing_sources = []
        for package_dir in [ROOT / "assets/kenney/1-bit-pack", ROOT / "assets/kenney/tiny-dungeon"]:
            if any(package_dir in png.parents for png in imported_pngs) and not (package_dir / "source.txt").is_file():
                missing_sources.append(str((package_dir / "source.txt").relative_to(ROOT)))
        if missing_sources:
            return fail("real PNG imports require package source files: " + ", ".join(missing_sources))
    print("asset ledger checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
