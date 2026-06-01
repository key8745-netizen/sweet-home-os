extends TileMapLayer
class_name GridWorld

@export var tile_size_px := 16
@export var floor_color := Color("#f2ddbf"):
	set(value):
		floor_color = value
		queue_redraw()

func _draw_checker_tiles() -> void:
	queue_redraw()

func _draw_grid_lines(world_size: Vector2) -> void:
	queue_redraw()

func _draw() -> void:
	var cols := int(get_viewport_rect().size.x / tile_size_px) + 2
	var rows := int(get_viewport_rect().size.y / tile_size_px) + 2
	for row in range(rows):
		for col in range(cols):
			var even := (row + col) % 2 == 0
			var color := floor_color if even else floor_color.darkened(0.06)
			draw_rect(Rect2(col * tile_size_px, row * tile_size_px, tile_size_px, tile_size_px), color)
	var grid_color := Color(floor_color.darkened(0.15), 0.4)
	for col in range(cols + 1):
		draw_line(Vector2(col * tile_size_px, 0), Vector2(col * tile_size_px, rows * tile_size_px), grid_color, 0.5)
	for row in range(rows + 1):
		draw_line(Vector2(0, row * tile_size_px), Vector2(cols * tile_size_px, row * tile_size_px), grid_color, 0.5)
