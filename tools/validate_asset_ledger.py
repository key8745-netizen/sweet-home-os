#!/usr/bin/env python3
"""validate_asset_ledger.py

Validates that:
1. research/asset-license-ledger.md exists and contains required sections.
2. Any asset file listed in decorations.json or hero_evolution.json that IS present
   in the repo is also listed in the ledger.
3. The assets/kenney/ staging directory structure is sane (no loose files outside
   named pack subdirectories).

Exit code 0 = all checks passed.
Exit code 1 = one or more checks failed.
"""

import json
import os
import re
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

LEDGER_PATH = os.path.join(REPO_ROOT, "research", "asset-license-ledger.md")
DECORATIONS_PATH = os.path.join(REPO_ROOT, "data", "decorations.json")
HERO_EVOLUTION_PATH = os.path.join(REPO_ROOT, "data", "hero_evolution.json")
KENNEY_ASSETS_DIR = os.path.join(REPO_ROOT, "assets", "kenney")

errors: list[str] = []
warnings: list[str] = []


# ---------------------------------------------------------------------------
# Check 1: Ledger exists and has required sections
# ---------------------------------------------------------------------------

def check_ledger_exists() -> str | None:
    if not os.path.isfile(LEDGER_PATH):
        return f"MISSING: {LEDGER_PATH}"
    return None


def check_ledger_sections(ledger_text: str) -> list[str]:
    required_sections = [
        "## License Key",
        "## Kenney Assets",
        "## Staging Checklist",
    ]
    missing = []
    for section in required_sections:
        if section not in ledger_text:
            missing.append(f"Ledger missing section: '{section}'")
    return missing


# ---------------------------------------------------------------------------
# Check 2: Staged asset files are in the ledger
# ---------------------------------------------------------------------------

def collect_referenced_sprite_paths() -> list[str]:
    """Return all sprite_path / sprite values from data JSON files."""
    paths: list[str] = []

    for data_file in [DECORATIONS_PATH, HERO_EVOLUTION_PATH]:
        if not os.path.isfile(data_file):
            warnings.append(f"Data file not found, skipping sprite check: {data_file}")
            continue
        with open(data_file, encoding="utf-8") as f:
            try:
                data = json.load(f)
            except json.JSONDecodeError as e:
                errors.append(f"JSON parse error in {data_file}: {e}")
                continue

        for item in data:
            for key in ("sprite_path", "sprite"):
                val = item.get(key, "")
                if val:
                    paths.append(val)

    return paths


def check_staged_assets_in_ledger(ledger_text: str, sprite_paths: list[str]) -> list[str]:
    """For each sprite path that actually exists on disk, verify its filename appears
    somewhere in the ledger."""
    missing_from_ledger: list[str] = []
    for rel_path in sprite_paths:
        abs_path = os.path.join(REPO_ROOT, rel_path)
        if os.path.isfile(abs_path):
            filename = os.path.basename(rel_path)
            if filename not in ledger_text:
                missing_from_ledger.append(
                    f"Staged asset '{rel_path}' is not listed in the ledger."
                )
    return missing_from_ledger


# ---------------------------------------------------------------------------
# Check 3: Kenney staging directory structure
# ---------------------------------------------------------------------------

def check_kenney_dir_structure() -> list[str]:
    """Loose files (not in a named pack subdirectory) under assets/kenney/ are flagged."""
    issues: list[str] = []
    if not os.path.isdir(KENNEY_ASSETS_DIR):
        # Not staged yet — that is OK in Phase 1.
        return issues

    for entry in os.listdir(KENNEY_ASSETS_DIR):
        full = os.path.join(KENNEY_ASSETS_DIR, entry)
        if os.path.isfile(full):
            issues.append(
                f"Loose file in assets/kenney/ (should be in a pack subdirectory): {entry}"
            )
    return issues


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    print("=== validate_asset_ledger.py ===\n")

    # Check 1
    err = check_ledger_exists()
    if err:
        errors.append(err)
        print(f"[FAIL] {err}")
    else:
        print(f"[OK] Ledger found: {LEDGER_PATH}")
        with open(LEDGER_PATH, encoding="utf-8") as f:
            ledger_text = f.read()

        section_errors = check_ledger_sections(ledger_text)
        for e in section_errors:
            errors.append(e)
            print(f"[FAIL] {e}")
        if not section_errors:
            print("[OK] All required ledger sections present.")

        # Check 2
        sprite_paths = collect_referenced_sprite_paths()
        staged_errors = check_staged_assets_in_ledger(ledger_text, sprite_paths)
        for e in staged_errors:
            errors.append(e)
            print(f"[FAIL] {e}")
        if not staged_errors:
            print(f"[OK] All {len(sprite_paths)} referenced sprite paths checked against ledger.")

        # Check 3
        dir_errors = check_kenney_dir_structure()
        for e in dir_errors:
            errors.append(e)
            print(f"[FAIL] {e}")
        if not dir_errors:
            print("[OK] assets/kenney/ directory structure valid (or not yet staged).")

    for w in warnings:
        print(f"[WARN] {w}")

    print()
    if errors:
        print(f"validate_asset_ledger: {len(errors)} error(s) found.")
        return 1
    else:
        print("validate_asset_ledger: all checks passed.")
        return 0


if __name__ == "__main__":
    sys.exit(main())
