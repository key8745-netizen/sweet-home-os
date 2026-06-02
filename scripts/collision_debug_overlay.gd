extends Node2D
class_name CollisionDebugOverlay

const DECORATIONS_PATH := "res://data/decorations.json"
const HERO_SPAWN := Vector2(250, 300)
const HERO_SAFE_RADIUS := 24.0
const QUEST_BOARD_CENTER := Vector2(610, 210)
const QUEST_BOARD_SIZE := Vector2(84, 60)
const BOARD_PADDING := 12.0
const HALL_BOUNDS := Rect2(Vector2(32, 36), Vector2(736, 416))
const WALL_GUIDE_RECTS := [
	Rect2(Vector2(20, 28), Vector2(760, 16)),
	Rect2(Vector2(20, 444), Vector2(760, 16)),
	Rect2(Vector2(24, 30), Vector2(16, 420)),
	Rect2(Vector2(760, 30), Vector2(16, 420)),
]

@export var show_debug := false:
	set(value):
		show_debug = value
		visible = value
		queue_redraw()

var decorations: Array = []

func _ready() -> void:
	visible = show_debug
	decorations = _load_json_array(DECORATIONS_PATH)
	queue_redraw()

func set_debug_visible(enabled: bool) -> void:
	show_debug = enabled

func _draw() -> void:
	if not show_debug:
		return
	_draw_rect_outline(HALL_BOUNDS, Color("#8ab6d6"), 2.0)
	for wall_rect in WALL_GUIDE_RECTS:
		_draw_rect_outline(wall_rect, Color("#c49a6c"), 1.5)
	_draw_rect_outline(_hero_safe_rect(), Color("#a5d6a7"), 2.0)
	_draw_rect_outline(_quest_board_safe_rect(), Color("#ffe08a"), 2.0)
	for decoration in decorations:
		var rect := _decoration_blocker_rect(decoration)
		if rect.size == Vector2.ZERO:
			continue
		_draw_rect_outline(rect, Color("#ff8a80"), 2.0)

func _draw_rect_outline(rect: Rect2, color: Color, width: float) -> void:
	draw_rect(rect, Color(color.r, color.g, color.b, 0.08), true)
	draw_rect(rect, color, false, width)

func _hero_safe_rect() -> Rect2:
	return Rect2(HERO_SPAWN - Vector2.ONE * HERO_SAFE_RADIUS, Vector2.ONE * HERO_SAFE_RADIUS * 2.0)

func _quest_board_safe_rect() -> Rect2:
	return Rect2(QUEST_BOARD_CENTER - QUEST_BOARD_SIZE / 2.0 - Vector2.ONE * BOARD_PADDING, QUEST_BOARD_SIZE + Vector2.ONE * BOARD_PADDING * 2.0)

func _decoration_blocker_rect(decoration: Dictionary) -> Rect2:
	if not bool(decoration.get("blocks_movement", false)):
		return Rect2()
	var position := _array_to_vector2(decoration.get("scene_position", []))
	var size := _array_to_vector2(decoration.get("collision_size", []))
	var offset := _array_to_vector2(decoration.get("collision_offset", [0, 0]))
	if size == Vector2.ZERO:
		return Rect2()
	return Rect2(position + offset - size / 2.0, size)

func _array_to_vector2(value) -> Vector2:
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO

func _load_json_array(path: String) -> Array:
	if not FileAccess.file_exists(path):
		return []
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Array else []
