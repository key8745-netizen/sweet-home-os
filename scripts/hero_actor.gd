## HeroActor — manages character sprite and evolution stage transitions.
## Loaded as an instanced scene (hero_actor.tscn) inside GuildHall.
extends Node2D

signal evolution_changed(stage_data: Dictionary)

var _evolution_stages: Array = []
var _current_stage: Dictionary = {}
var _current_xp: int = 0

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _stage_label: Label = $StageLabel

const EVOLUTION_DATA_PATH := "res://data/hero_evolution.json"

func _ready() -> void:
	_load_evolution_data()
	setup_evolution(_current_xp)

func _load_evolution_data() -> void:
	if not FileAccess.file_exists(EVOLUTION_DATA_PATH):
		push_warning("HeroActor: hero_evolution.json not found at %s" % EVOLUTION_DATA_PATH)
		return
	var file := FileAccess.open(EVOLUTION_DATA_PATH, FileAccess.READ)
	var json_text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(json_text)
	if parsed == null or not (parsed is Array):
		push_error("HeroActor: failed to parse hero_evolution.json")
		return
	_evolution_stages = parsed

## Public entry point — call whenever total XP changes.
func setup_evolution(total_xp: int) -> void:
	_current_xp = total_xp
	var new_stage := _stage_for_xp(total_xp)
	if new_stage.is_empty():
		return

	var stage_changed := _current_stage.get("stage", -1) != new_stage.get("stage", -1)
	_current_stage = new_stage
	_apply_stage(new_stage)

	if stage_changed:
		evolution_changed.emit(new_stage)

func _stage_for_xp(xp: int) -> Dictionary:
	# Iterate in reverse so highest qualifying stage wins
	var best: Dictionary = {}
	for stage in _evolution_stages:
		if xp >= int(stage.get("min_xp", 0)):
			best = stage
	return best

func _apply_stage(stage: Dictionary) -> void:
	# Update label
	if _stage_label != null:
		_stage_label.text = stage.get("name", "")

	# Attempt to load sprite
	if _sprite == null:
		return
	var sprite_path: String = stage.get("sprite", "")
	if sprite_path == "":
		return
	var full_path := "res://" + sprite_path
	if ResourceLoader.exists(full_path):
		_sprite.texture = load(full_path) as Texture2D
	else:
		# Placeholder: tint sprite a stage-specific colour so changes are visible
		var tints: Array[Color] = [Color.WHITE, Color.CYAN, Color.GOLD]
		var idx: int = clamp(int(stage.get("stage", 1)) - 1, 0, tints.size() - 1)
		_sprite.modulate = tints[idx]

## Returns current stage dict (read-only copy).
func get_current_stage() -> Dictionary:
	return _current_stage.duplicate()

## Returns current total XP tracked by this actor.
func get_xp() -> int:
	return _current_xp
