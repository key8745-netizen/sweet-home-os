# Growth Feedback — Sweet Home OS

This document describes how the game communicates progress to the child and family.

## Decoration Unlock Queue

When `total_xp` crosses a decoration threshold, the unlock is queued rather than
shown immediately. This prevents multiple overlays stacking at once.

- Only one `UnlockPanel` overlay is visible at a time.
- The `UnlockTimer` (2 s) advances the queue after each overlay is dismissed.
- `SoundManager.play_unlock_decor_sound()` plays on each unlock.

## Background Color Tween

The `World/FloorTileMapLayer` floor color tweens across XP bands:

| XP Range | Color |
|----------|-------|
| 0–29 | `#f2ddbf` (warm sand) |
| 30–59 | `#c6e0f2` (cool blue) |
| 60+ | `#d8c6f2` (gentle purple) |

## Family-Safe Tone Guidelines

Use family-safe narration, avoid shame, and frame progress as helping the home guild grow together.

- No streak loss, no penalties, no sibling comparison.
- Quest completion messages should be warm and specific to the task.
- Decoration unlock text celebrates the whole family, not a single child.
- The parent PIN gate is framed as a celebratory confirmation, not surveillance.
