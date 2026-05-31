# Interaction System

## Overview

The hero character can walk up to interactable objects in the guild hall and press `ui_accept` (Space or Enter) to interact.

## Components

### InteractionArea (Area2D on HeroActor)
- Positioned in front of the hero based on `_facing_vector()`
- When an interactable Area2D enters this area, `current_interactable` is set
- When the area exits, `current_interactable` is cleared

### InteractPrompt (Label on HeroActor)
- Visible only when `current_interactable != null`
- Shows text from `get_interact_prompt()` on the interactable, or "Interact" as fallback

### QuestBoardObject (Area2D in GuildHall)
- Has `signal interacted` that GuildHall connects to `_on_quest_board_interacted()`
- Implements `interact(_hero)` — emits the signal
- Implements `get_interact_prompt()` — returns configurable prompt text

## Adding New Interactables

1. Create an Area2D node with a CollisionShape2D
2. Attach a script with:
   - `signal interacted` (optional)
   - `func interact(_hero: Node = null) -> void:`
   - `func get_interact_prompt() -> String:`
3. Connect to the GuildHall or handle internally

## Input

`ui_accept` is the canonical action. It maps to Space, Enter, and gamepad A by default in Godot 4.
