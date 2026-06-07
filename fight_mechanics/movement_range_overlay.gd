extends Node2D
class_name MovementRangeOverlay

const PLAYER_FILL_COLOR := Color(0.45, 0.95, 0.6, 0.18)
const PLAYER_OUTLINE_COLOR := Color(0.65, 1.0, 0.78, 0.55)
const ENEMY_FILL_COLOR := Color(0.95, 0.35, 0.35, 0.16)
const ENEMY_OUTLINE_COLOR := Color(1.0, 0.55, 0.55, 0.5)
const OUTLINE_WIDTH := 2.0

var navigation_provider: GridNavigationProvider
var _player_cells: Array[Vector2i] = []
var _enemy_cells: Array[Vector2i] = []

func _ready() -> void:
	z_index = 0

func set_navigation_provider(provider: GridNavigationProvider) -> void:
	navigation_provider = provider
	queue_redraw()

func set_player_cells(cells: Array[Vector2i]) -> void:
	_player_cells = cells.duplicate()
	queue_redraw()

func set_enemy_cells(cells: Array[Vector2i]) -> void:
	_enemy_cells = cells.duplicate()
	queue_redraw()

func clear() -> void:
	_player_cells.clear()
	_enemy_cells.clear()
	queue_redraw()

func _draw() -> void:
	_draw_cells(_player_cells, PLAYER_FILL_COLOR, PLAYER_OUTLINE_COLOR)
	_draw_cells(_enemy_cells, ENEMY_FILL_COLOR, ENEMY_OUTLINE_COLOR)

func _draw_cells(cells: Array[Vector2i], fill_color: Color, outline_color: Color) -> void:
	var floor_layer := _get_floor_layer()
	if floor_layer == null or floor_layer.tile_set == null or cells.is_empty():
		return

	var cell_lookup := {}
	for cell in cells:
		cell_lookup[cell] = true

	var half_tile_size := Vector2(floor_layer.tile_set.tile_size) * 0.5

	for cell in cells:
		var center_local := floor_layer.map_to_local(cell)
		var top_left := to_local(floor_layer.to_global(center_local + Vector2(-half_tile_size.x, -half_tile_size.y)))
		var top_right := to_local(floor_layer.to_global(center_local + Vector2(half_tile_size.x, -half_tile_size.y)))
		var bottom_right := to_local(floor_layer.to_global(center_local + Vector2(half_tile_size.x, half_tile_size.y)))
		var bottom_left := to_local(floor_layer.to_global(center_local + Vector2(-half_tile_size.x, half_tile_size.y)))
		var polygon := PackedVector2Array([top_left, top_right, bottom_right, bottom_left])

		draw_colored_polygon(polygon, fill_color)

		if not cell_lookup.has(cell + Vector2i.UP):
			draw_line(top_left, top_right, outline_color, OUTLINE_WIDTH)
		if not cell_lookup.has(cell + Vector2i.RIGHT):
			draw_line(top_right, bottom_right, outline_color, OUTLINE_WIDTH)
		if not cell_lookup.has(cell + Vector2i.DOWN):
			draw_line(bottom_right, bottom_left, outline_color, OUTLINE_WIDTH)
		if not cell_lookup.has(cell + Vector2i.LEFT):
			draw_line(bottom_left, top_left, outline_color, OUTLINE_WIDTH)

func _get_floor_layer() -> TileMapLayer:
	if navigation_provider == null:
		return null
	if not is_instance_valid(navigation_provider):
		return null
	return navigation_provider.get_floor_layer()
