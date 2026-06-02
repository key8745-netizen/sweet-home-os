extends TileMapLayer
class_name WallTileMapLayer

## Procedural, fallback-first wall guide for the guild hall boundary pass.
## The authoritative physics still lives in World/Boundaries, while this layer
## makes those grid-aligned limits visible without importing external tiles.

@export var wall_color := Color("#6f4d38"):
	set(value):
		wall_color = value
		queue_redraw()
@export var wall_shadow_color := Color("#3f2a22"):
	set(value):
		wall_shadow_color = value
		queue_redraw()
@export var wall_highlight_color := Color("#9b7658"):
	set(value):
		wall_highlight_color = value
		queue_redraw()
@export var tile_size_px := 16:
	set(value):
		tile_size_px = max(1, value)
		queue_redraw()
@export var top_wall_rect := Rect2(Vector2(20, 28), Vector2(760, 16)):
	set(value):
		top_wall_rect = value
		queue_redraw()
@export var bottom_wall_rect := Rect2(Vector2(20, 444), Vector2(760, 16)):
	set(value):
		bottom_wall_rect = value
		queue_redraw()
@export var left_wall_rect := Rect2(Vector2(24, 30), Vector2(16, 420)):
	set(value):
		left_wall_rect = value
		queue_redraw()
@export var right_wall_rect := Rect2(Vector2(760, 30), Vector2(16, 420)):
	set(value):
		right_wall_rect = value
		queue_redraw()

func _ready() -> void:
	z_index = -60
	queue_redraw()

func _draw() -> void:
	_draw_wall_band(top_wall_rect, true)
	_draw_wall_band(bottom_wall_rect, true)
	_draw_wall_band(left_wall_rect, false)
	_draw_wall_band(right_wall_rect, false)

func get_wall_rects() -> Array[Rect2]:
	return [top_wall_rect, bottom_wall_rect, left_wall_rect, right_wall_rect]

func _draw_wall_band(rect: Rect2, horizontal := true) -> void:
	draw_rect(rect, wall_shadow_color, true)
	var inset_rect := rect.grow(-2.0)
	if inset_rect.size.x > 0.0 and inset_rect.size.y > 0.0:
		draw_rect(inset_rect, wall_color, true)
	var highlight_start := rect.position + Vector2(2, 2)
	var highlight_end := rect.position + (Vector2(rect.size.x - 2, 2) if horizontal else Vector2(2, rect.size.y - 2))
	draw_line(highlight_start, highlight_end, wall_highlight_color, 2.0)
	_draw_tile_ticks(rect, horizontal)

func _draw_tile_ticks(rect: Rect2, horizontal := true) -> void:
	var tick_color := wall_shadow_color.lightened(0.18)
	if horizontal:
		var x := rect.position.x
		while x <= rect.end.x:
			draw_line(Vector2(x, rect.position.y + 3.0), Vector2(x, rect.end.y - 3.0), tick_color, 1.0)
			x += float(tile_size_px)
	else:
		var y := rect.position.y
		while y <= rect.end.y:
			draw_line(Vector2(rect.position.x + 3.0, y), Vector2(rect.end.x - 3.0, y), tick_color, 1.0)
			y += float(tile_size_px)
