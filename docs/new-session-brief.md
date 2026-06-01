# New Session Brief — Sweet Home OS

Use this document as the opening prompt when starting a fresh AI-agent session.

## Canonical branch: work

The canonical reference is the **work** branch. Active development branch: `claude/adoring-bell-dv270`.

## Short Chinese Opening Prompt

請先執行 `python3 tools/verify_current_state.py` 及 `python3 tools/validate_asset_ledger.py`，確認 baseline 完整後再閱讀 `docs/current-state.md`，然後開始工作。一律用繁體中文回答。

## Full Opening Prompt

You are continuing development on Sweet Home OS, a Godot 4.x household-management JRPG. Before making any changes:

1. Run `python3 tools/verify_current_state.py` to confirm the baseline is intact.
2. Run `python3 tools/validate_asset_ledger.py` to confirm asset documentation is intact.
3. Read `docs/current-state.md` for the authoritative summary of what is implemented.
4. Only then begin the requested task.

Development branch: **claude/adoring-bell-dv270**. All commits go here.

Respond in Traditional Chinese (繁體中文) throughout the session.

## Session Handoff Checklist

Before ending a session:
- [ ] All new/modified files committed and pushed
- [ ] `python3 tools/verify_current_state.py` passes
- [ ] `python3 tools/validate_asset_ledger.py` passes
- [ ] `docs/current-state.md` updated if scope changed
- [ ] `docs/open-new-conversation.md` updated to reflect new state
