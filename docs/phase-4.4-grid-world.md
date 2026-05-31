# Phase 4.4 — GridWorld TileMapLayer

## Overview

The guild hall floor uses a `TileMapLayer`-based `GridWorld` node to provide a
procedural checker-tile floor with XP-reactive color tweening.

## Node Path

`World/FloorTileMapLayer` (type: `GridWorld extends TileMapLayer`)

## Scene Structure

```
GuildHall (Node2D)
└── World (Node2D)
    ├── FloorTileMapLayer (GridWorld)   ← checker floor
    └── YSortLayer (Node2D, y_sort_enabled=true)
        ├── HeroActor
        ├── QuestBoardObject
        └── [decorations added at runtime]
```

## floor_color Property

`floor_color` is an `@export` property on `GridWorld`. Setting it triggers `queue_redraw()`.
`guild_hall.gd` tweens it via:
```gdscript
background_tween.tween_property(background, "floor_color", target, 0.4)
```

## World/YSortLayer

All in-world sprites (hero, decorations, quest board) live under `YSortLayer`
so they are y-sorted automatically by Godot.
