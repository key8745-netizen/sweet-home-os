extends CharacterBody2D

const SPEED := 80.0
const EVOLUTION_DATA_PATH := "res://data/hero_evolution.json"

var _stages: Array = []
var _current_stage: Dictionary = {}
var _facing := Vector2.DOWN
var _proc_time := 0.0
var _fallback_rect: ColorRect


func _ready() -> void:
	_load_evolution_data()
	_build_fallback_visual()
	setup_evolution(0)


func _load_evolution_data() -> void:
	if not FileAccess.file_exists(EVOLUTION_DATA_PATH):
		return
	var file := FileAccess.open(EVOLUTION_DATA_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_stages = parsed.get("stages", [])


func _build_fallback_visual() -> void:
	_fallback_rect = ColorRect.new()
	_fallback_rect.size = Vector2(24, 24)
	_fallback_rect.position = Vector2(-12, -12)
	_fallback_rect.color = Color(0.47, 0.53, 0.80)
	add_child(_fallback_rect)


func setup_evolution(p_total_xp: int) -> void:
	var selected: Dictionary = {}
	for stage in _stages:
		if not stage is Dictionary:
			continue
		if p_total_xp >= int(stage.get("required_xp", 0)):
			selected = stage

	if selected.is_empty() and not _stages.is_empty():
		selected = _stages[0]

	_current_stage = selected

	if _fallback_rect == null:
		return

	var size := float(_current_stage.get("fallback_size", 24))
	_fallback_rect.size = Vector2(size, size)
	_fallback_rect.position = Vector2(-size / 2.0, -size / 2.0)

	var hex: String = str(_current_stage.get("fallback_color", "#7986cb"))
	_fallback_rect.color = Color.html(hex) if hex.begins_with("#") else Color(0.47, 0.53, 0.80)


func _physics_process(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		dir.x += 1.0
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("ui_down"):
		dir.y += 1.0
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1.0

	if dir != Vector2.ZERO:
		_facing = dir.normalized()
		velocity = dir.normalized() * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	_update_procedural_motion(delta)


func _update_procedural_motion(delta: float) -> void:
	_proc_time += delta
	if _fallback_rect == null:
		return
	var base_size := float(_current_stage.get("fallback_size", 24))
	var breathe := sin(_proc_time * 2.0) * 1.5
	var s := base_size + breathe
	_fallback_rect.size = Vector2(s, s)
	_fallback_rect.position = Vector2(-s / 2.0, -s / 2.0)
