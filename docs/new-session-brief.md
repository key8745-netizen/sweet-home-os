# New Session Brief — Sweet Home OS

Use this document as the opening prompt when starting a fresh AI-agent session.

## Canonical branch: work

All changes go to the `work` branch. Do not create new branches or push to main.

## Short Chinese Opening Prompt

請先閱讀 `docs/current-state.md`，再執行 `python3 tools/verify_current_state.py`，確認 baseline 完整後再開始工作。

## Full Opening Prompt

You are continuing development on Sweet Home OS, a Godot 4.x household-management JRPG. Before making any changes:

1. Read `docs/current-state.md` for the authoritative summary of what is implemented.
2. Run `python3 tools/verify_current_state.py` to confirm the baseline is intact.
3. Run `python3 tools/validate_asset_ledger.py` to confirm asset documentation is intact.
4. Only then begin the requested task.

Canonical branch: **work**. All commits go here.

## Session Handoff Checklist

Before ending a session:
- [ ] All new/modified files committed
- [ ] `python3 tools/verify_current_state.py` passes
- [ ] `python3 tools/validate_asset_ledger.py` passes
- [ ] `python3 tools/godot_smoke_test.py` (skips cleanly if Godot unavailable; use `--require-godot` in CI)
- [ ] `docs/current-state.md` updated if scope changed
- [ ] Branch pushed to remote
