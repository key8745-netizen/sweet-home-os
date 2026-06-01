extends Node2D
class_name DecorPlaceholder

@export var display_name := "Decoration"  # populated from JSON "name" field
@export var sprite_path := ""
@export var fallback_color := Color("#f6d36b")
@export_enum("banner", "rug", "candle", "plant", "shelf", "lantern", "circle") var fallback_shape: String = "circle"

var _sprite := Sprite2D.new()

func _ready() -> void:
	add_child(_sprite)
	_load_sprite_or_fallback()

func setup(decoration: Dictionary) -> void:
	display_name = str(decoration.get("name", decoration.get("display_name", display_name)))
	sprite_path = str(decoration.get("sprite_path", sprite_path))
	fallback_color = Color(str(decoration.get("color", "#f6d36b")))
	fallback_shape = str(decoration.get("shape", fallback_shape))
	if is_inside_tree():
		_load_sprite_or_fallback()

func _load_sprite_or_fallback() -> void:
	if sprite_path != "" and ResourceLoader.exists(sprite_path):
		_sprite.texture = load(sprite_path)
		_sprite.visible = true
		queue_redraw()
		return
	_sprite.texture = null
	_sprite.visible = false
	queue_redraw()

func _draw() -> void:
	if _sprite.texture != null:
		return
	match fallback_shape:
		"banner":
			_draw_banner()
		"rug":
			_draw_rug()
		"candle":
			_draw_candle()
		"plant":
			_draw_plant()
		"shelf":
			_draw_shelf()
		"lantern":
			_draw_lantern()
		_:
			_draw_circle_badge()
	var font := ThemeDB.get_fallback_font()
	draw_string(font, Vector2(-48, 38), display_name, HORIZONTAL_ALIGNMENT_CENTER, 96, 12, Color("#3d2d2d"))

func _draw_banner() -> void:
	var points := PackedVector2Array([Vector2(-34, -18), Vector2(34, -18), Vector2(28, 16), Vector2(0, 6), Vector2(-28, 16)])
	draw_colored_polygon(points, fallback_color)
	var closed_points := PackedVector2Array([points[0], points[1], points[2], points[3], points[4], points[0]])
	draw_polyline(closed_points, fallback_color.darkened(0.35), 2.0)

func _draw_rug() -> void:
	draw_rect(Rect2(Vector2(-40, -15), Vector2(80, 30)), fallback_color, true)
	draw_rect(Rect2(Vector2(-40, -15), Vector2(80, 30)), fallback_color.darkened(0.3), false, 2.0)
	draw_line(Vector2(-28, 0), Vector2(28, 0), Color(1.0, 1.0, 1.0, 0.35), 2.0)

func _draw_candle() -> void:
	draw_rect(Rect2(Vector2(-8, -10), Vector2(16, 30)), fallback_color, true)
	draw_circle(Vector2(0, -20), 8.0, Color("#ffe08a"))
	draw_rect(Rect2(Vector2(-18, 20), Vector2(36, 6)), fallback_color.darkened(0.25), true)

func _draw_plant() -> void:
	draw_rect(Rect2(Vector2(-16, 8), Vector2(32, 18)), fallback_color.darkened(0.25), true)
	draw_circle(Vector2(-10, -6), 13.0, fallback_color)
	draw_circle(Vector2(9, -10), 15.0, fallback_color.lightened(0.1))
	draw_line(Vector2(0, 12), Vector2(0, -20), fallback_color.darkened(0.45), 3.0)

func _draw_shelf() -> void:
	draw_rect(Rect2(Vector2(-28, -18), Vector2(56, 36)), fallback_color.darkened(0.18), true)
	draw_rect(Rect2(Vector2(-28, -18), Vector2(56, 36)), fallback_color.darkened(0.38), false, 2.0)
	draw_line(Vector2(-24, -2), Vector2(24, -2), fallback_color.darkened(0.45), 2.0)
	draw_rect(Rect2(Vector2(-20, -14), Vector2(8, 10)), Color("#f6d36b"), true)

func _draw_lantern() -> void:
	draw_line(Vector2(0, -30), Vector2(0, -18), fallback_color.darkened(0.4), 2.0)
	draw_circle(Vector2(0, 0), 20.0, fallback_color)
	draw_circle(Vector2(0, 0), 10.0, Color("#fff1a8"))
	draw_rect(Rect2(Vector2(-18, 18), Vector2(36, 5)), fallback_color.darkened(0.3), true)

func _draw_circle_badge() -> void:
	draw_circle(Vector2.ZERO, 18.0, fallback_color)
	draw_rect(Rect2(Vector2(-18, 6), Vector2(36, 8)), fallback_color.darkened(0.2), true)

func play_unlock_pop() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.12)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.18)
