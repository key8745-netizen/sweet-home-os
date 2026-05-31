## HeroActor — manages character movement, interaction, and evolution stage transitions.
## Loaded as an instanced scene (hero_actor.tscn) inside GuildHall.
extends CharacterBody2D
class_name HeroActor

signal evolution_changed(stage_data: Dictionary)

const EVOLUTION_DATA_PATH := "res://data/hero_evolution.json"
const MOVE_SPEED := 120.0

var _evolution_stages: Array = []
var _current_stage: Dictionary = {}
var _current_xp: int = 0
var _facing := Vector2.DOWN
var _current_interactable: Node = null
var _breath_time := 0.0

@onready var _sprite: Node2D = $FallbackBody
@onready var _stage_label: Label = $StageLabel
@onready var _interact_prompt: Label = $InteractPrompt
@onready var _interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	_load_evolution_data()
	setup_evolution(_current_xp)
	_interact_prompt.visible = false
	_interaction_area.body_entered.connect(_on_interactable_entered)
	_interaction_area.body_exited.connect(_on_interactable_exited)

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
func setup_evolution(p_total_xp: int) -> void:
	_current_xp = p_total_xp
	var new_stage := _stage_for_xp(p_total_xp)
	if new_stage.is_empty():
		return
	var stage_changed := _current_stage.get("stage", -1) != new_stage.get("stage", -1)
	_current_stage = new_stage
	_apply_stage(new_stage)
	if stage_changed:
		evolution_changed.emit(new_stage)

func _physics_process(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("ui_right"):
		dir.x += 1.0
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1.0
	if Input.is_action_pressed("ui_down"):
		dir.y += 1.0
	if dir != Vector2.ZERO:
		_facing = dir.normalized()
	velocity = dir.normalized() * MOVE_SPEED
	move_and_slide()
	_update_procedural_motion(delta)
	_update_current_interactable()
	if Input.is_action_just_pressed("ui_accept"):
		_try_interact()

func _update_procedural_motion(delta: float) -> void:
	_breath_time += delta
	if _sprite != null:
		_sprite.scale = Vector2.ONE * (1.0 + sin(_breath_time * 2.0) * 0.03)

func _try_interact() -> void:
	if _current_interactable == null:
		return
	if _current_interactable.has_method("interact"):
		_current_interactable.interact(self)

func _update_current_interactable() -> void:
	var overlapping := _interaction_area.get_overlapping_areas()
	var best: Node = null
	var best_dist := INF
	for area in overlapping:
		if area.has_method("interact"):
			var d := position.distance_to(area.global_position)
			if d < best_dist:
				best_dist = d
				best = area
	_current_interactable = best
	if _interact_prompt != null:
		if best != null and best.has_method("get_interact_prompt"):
			_interact_prompt.text = best.get_interact_prompt()
			_interact_prompt.visible = true
		else:
			_interact_prompt.visible = false

func _facing_vector() -> Vector2:
	return _facing

func _on_interactable_entered(_body: Node) -> void:
	_update_current_interactable()

func _on_interactable_exited(_body: Node) -> void:
	_update_current_interactable()

func _stage_for_xp(xp: int) -> Dictionary:
	var best: Dictionary = {}
	for stage in _evolution_stages:
		if xp >= int(stage.get("min_xp", 0)):
			best = stage
	return best

func _apply_stage(stage: Dictionary) -> void:
	if _stage_label != null:
		_stage_label.text = stage.get("name", "")

## Returns current stage dict (read-only copy).
func get_current_stage() -> Dictionary:
	return _current_stage.duplicate()

## Returns current total XP tracked by this actor.
func get_xp() -> int:
	return _current_xp
