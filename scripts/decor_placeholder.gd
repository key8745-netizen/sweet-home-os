## DecorPlaceholder — renders a single decoration item.
## Priority: load sprite from sprite_path; fall back to coloured geometry shape.
extends Node2D

## Decoration data dict loaded from decorations.json
var decor_data: Dictionary = {}

# Internal nodes created at runtime
var _sprite: Sprite2D = null
var _fallback_rect: ColorRect = null
var _label: Label = null

const FALLBACK_SIZE := Vector2(64, 64)
const FALLBACK_COLORS: Array[Color] = [
	Color(0.8, 0.6, 0.2),  # gold
	Color(0.6, 0.4, 0.8),  # purple
	Color(0.3, 0.7, 0.5),  # green
	Color(0.9, 0.4, 0.3),  # red-orange
	Color(0.3, 0.5, 0.9),  # blue
]

func _ready() -> void:
	if decor_data.is_empty():
		return
	_build()

## Call this after setting decor_data if not going through _ready.
func setup(data: Dictionary) -> void:
	decor_data = data
	_build()

func _build() -> void:
	# Clean up any previously created children
	for child in get_children():
		child.queue_free()
	_sprite = null
	_fallback_rect = null

	var sprite_path: String = decor_data.get("sprite_path", "")
	if sprite_path != "":
		_try_load_sprite(sprite_path)

	if _sprite == null:
		_build_fallback()

	_build_label()

func _try_load_sprite(path: String) -> void:
	var full_path := "res://" + path
	if ResourceLoader.exists(full_path):
		var tex := load(full_path) as Texture2D
		if tex != null:
			_sprite = Sprite2D.new()
			_sprite.texture = tex
			_sprite.centered = true
			add_child(_sprite)

func _build_fallback() -> void:
	# Pick a colour based on the decoration's position in the array
	var idx: int = 0
	var id: String = decor_data.get("id", "")
	# Simple deterministic colour from id hash
	if id != "":
		idx = (id.hash() & 0x7FFFFFFF) % FALLBACK_COLORS.size()
	var color := FALLBACK_COLORS[idx]

	_fallback_rect = ColorRect.new()
	_fallback_rect.color = color
	_fallback_rect.size = FALLBACK_SIZE
	# Centre the rect on Node2D origin
	_fallback_rect.position = -FALLBACK_SIZE / 2.0
	add_child(_fallback_rect)

func _build_label() -> void:
	_label = Label.new()
	_label.text = decor_data.get("name", "")
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 10)
	# Position below the sprite/rect
	_label.position = Vector2(-48, 36)
	_label.custom_minimum_size = Vector2(96, 16)
	add_child(_label)
