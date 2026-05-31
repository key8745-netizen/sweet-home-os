# Sweet Home OS Design Plan

Sweet Home OS turns routine household support into a cozy JRPG guild-hall ritual. The player is not being monitored or ranked; they are practicing autonomy, care, and visible contribution to the home.

## Experience Pillars

1. **Warm autonomy** — children choose from clear, bounded quests rather than receiving a punishment list.
2. **Family cooperation** — quests can mention nearby grown-up support, especially for safety-sensitive tasks.
3. **Visible growth** — XP unlocks decorations and hero stages that make the guild hall feel more lived-in.
4. **No shame loops** — no streak loss, sibling comparison, leaderboards, or surveillance framing.
5. **Placeholder-first production** — missing sprites must degrade into readable procedural visuals until licensed assets are staged.

## Phase 1 Runtime Loop

1. The child moves the hero around the guild hall.
2. The child approaches the in-world quest board and presses `ui_accept` / Space / Enter.
3. The quest UI opens with data-driven cards from `data/quests.json`.
4. The child accepts one quest and later reports it complete.
5. Local XP increases, hero evolution refreshes, background color may tween, and newly unlocked decorations appear through a queued overlay.

## Phase 2 Candidate Tickets

- Add a parent confirmation gate before XP is granted.
- Add local save/load for XP, accepted quest, and already-shown unlocks.
- Add a small settings/help panel explaining family-safe use.
- Add more interactable objects only if they preserve the low-friction family tone.
