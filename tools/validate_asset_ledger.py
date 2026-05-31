#!/usr/bin/env python3
"""Validate asset-staging documentation markers.

Checks that the asset license ledger exists and contains the required
structural markers. Fails with a non-zero exit code if anything is missing.
"""

from pathlib import Path

LEDGER_PATH = "docs/research/asset-license-ledger.md"

REQUIRED_MARKERS = [
    "APPROVED",
    "PENDING",
    "REJECTED",
    "CC0",
    "source.txt",
    "Placeholder Policy",
]


def main() -> None:
    ledger = Path(LEDGER_PATH)
    if not ledger.exists():
        raise SystemExit(f"Missing asset ledger: {LEDGER_PATH}")

    text = ledger.read_text(encoding="utf-8")
    missing = [m for m in REQUIRED_MARKERS if m not in text]
    if missing:
        raise SystemExit(f"Asset ledger is missing required markers: {missing}")

    print("asset ledger checks passed")


if __name__ == "__main__":
    main()
