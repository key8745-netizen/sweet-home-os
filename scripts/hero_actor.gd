## HeroActor — walk-and-interact character controller with evolution stages.
## Loaded as an instanced scene (hero_actor.tscn) inside GuildHall.
extends CharacterBody2D

signal evolution_changed(stage_data: Dictionary)

var _evolution_stages: Array = []
var _current_stage: Dictionary = {}
var _total_xp: int = 0
var current_interactable: Node = null

@onready var _sprite: Sprite2D           = $Sprite2D
@onready var _fallback_body: Polygon2D   = $FallbackBody
@onready var _interact_area: Area2D      = $InteractionArea
@onready var _interact_prompt: Label     = $InteractPrompt

const EVOLUTION_DATA_PATH := "res://data/hero_evolution.json"
const MOVE_SPEED := 180.0

var _breath_time: float = 0.0

func _ready() -> void:
	_load_evolution_data()
	setup_evolution(0)

	if _interact_area != null:
		_interact_area.area_entered.connect(_on_interaction_area_entered)
		_interact_area.area_exited.connect(_on_interaction_area_exited)

func _load_evolution_data() -> void:
	if not FileAccess.file_exists(EVOLUTION_DATA_PATH):
		push_warning("HeroActor: hero_evolution.json not found")
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
	_total_xp = p_total_xp
	var new_stage := _stage_for_xp(p_total_xp)
	if new_stage.is_empty():
		return
	var stage_changed := _current_stage.get("id", "") != new_stage.get("id", "")
	_current_stage = new_stage
	_apply_stage(new_stage)
	if stage_changed:
		evolution_changed.emit(new_stage)

func _physics_process(delta: float) -> void:
	_handle_movement()
	_update_procedural_motion(delta)
	_update_current_interactable()
	if Input.is_action_just_pressed("ui_accept"):
		_try_interact()

func _handle_movement() -> void:
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	if direction.length() > 1.0:
		direction = direction.normalized()
	velocity = direction * MOVE_SPEED
	move_and_slide()

	# Keep interaction area facing the hero's movement direction
	if direction != Vector2.ZERO and _interact_area != null:
		_interact_area.position = _facing_vector() * 28.0

func _update_procedural_motion(delta: float) -> void:
	if velocity.length() < 1.0 and _fallback_body != null:
		_breath_time += delta
		_fallback_body.position.y = sin(_breath_time * 2.0) * 2.5

func _try_interact() -> void:
	if current_interactable == null:
		return
	if current_interactable.has_method("interact"):
		current_interactable.interact(self)

func _update_current_interactable() -> void:
	if _interact_prompt == null:
		return
	if current_interactable != null:
		var prompt := "Interact"
		if current_interactable.has_method("get_interact_prompt"):
			prompt = current_interactable.get_interact_prompt()
		_interact_prompt.text = prompt
		_interact_prompt.visible = true
	else:
		_interact_prompt.visible = false

func _facing_vector() -> Vector2:
	if velocity.length() > 1.0:
		return velocity.normalized()
	return Vector2.DOWN

func _on_interaction_area_entered(area: Area2D) -> void:
	if area.has_method("interact"):
		current_interactable = area

func _on_interaction_area_exited(area: Area2D) -> void:
	if current_interactable == area:
		current_interactable = null

func _stage_for_xp(xp: int) -> Dictionary:
	var best: Dictionary = {}
	for stage in _evolution_stages:
		if xp >= int(stage.get("required_total_xp", 0)):
			best = stage
	return best

func _apply_stage(stage: Dictionary) -> void:
	var body_color_str: String = stage.get("body_color", "#8cce7e")
	if _fallback_body != null:
		_fallback_body.color = Color(body_color_str)
	if _sprite == null:
		return
	var sprite_path: String = stage.get("sprite_path", "")
	if sprite_path != "" and ResourceLoader.exists(sprite_path):
		_sprite.texture = load(sprite_path) as Texture2D
		_sprite.visible = true
		if _fallback_body != null:
			_fallback_body.visible = false
	else:
		_sprite.visible = false
		if _fallback_body != null:
			_fallback_body.visible = true

## Returns current total XP tracked by this actor.
func get_xp() -> int:
	return _total_xp
