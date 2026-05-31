extends Node2D

var _data: Dictionary = {}
var _rect: ColorRect


func setup(decoration_data: Dictionary) -> void:
	_data = decoration_data

	var pos_data: Dictionary = _data.get("position", {"x": 0, "y": 0})
	position = Vector2(float(pos_data.get("x", 0)), float(pos_data.get("y", 0)))

	_rect = ColorRect.new()
	_rect.size = Vector2(32, 32)
	_rect.position = Vector2(-16, -16)

	var hex: String = str(_data.get("color", "#888888"))
	_rect.color = Color.html(hex) if hex.begins_with("#") else Color.GRAY

	add_child(_rect)

	var label := Label.new()
	label.text = str(_data.get("name", ""))
	label.position = Vector2(-24, 34)
	label.add_theme_font_size_override("font_size", 10)
	add_child(label)
