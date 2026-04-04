extends RefCounted
class_name GridMovementController

var astar_grid: AStarGrid2D
var path_to_travel: Array[Vector2i] = []

var movement_speed: float = 2.0
var max_move_distance: int = -1

var floor_layer: TileMapLayer
var walls_layer: TileMapLayer

func setup(
	p_floor_layer: TileMapLayer,
	p_walls_layer: TileMapLayer,
	p_movement_speed: float = 2.0,
	p_max_move_distance: int = -1
) -> void:
	floor_layer = p_floor_layer
	walls_layer = p_walls_layer
	movement_speed = p_movement_speed
	max_move_distance = p_max_move_distance
	_rebuild_navigation()

func _rebuild_navigation() -> void:
	astar_grid = AStarGrid2D.new()
	var used_rect = floor_layer.get_used_rect()

	astar_grid.region = used_rect
	astar_grid.cell_size = Vector2(floor_layer.tile_set.tile_size)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.update()

	for cell in walls_layer.get_used_cells():
		astar_grid.set_point_solid(cell, true)

func request_path(start_global_position: Vector2, end_global_position: Vector2) -> bool:
	if astar_grid == null or floor_layer == null:
		return false

	var start = floor_layer.local_to_map(
		floor_layer.to_local(start_global_position)
	)
	var end = floor_layer.local_to_map(
		floor_layer.to_local(end_global_position)
	)

	var id_path = astar_grid.get_id_path(start, end).slice(1)

	if max_move_distance >= 0 and id_path.size() > max_move_distance:
		return false

	if id_path.is_empty():
		return false

	path_to_travel = id_path
	return true

func clear_path():
	path_to_travel = []

func move_body(body: Node2D) -> bool:
	if floor_layer == null:
		return false

	if path_to_travel.is_empty():
		return false

	var target_position = floor_layer.to_global(
		floor_layer.map_to_local(path_to_travel.front())
	)
	body.global_position = body.global_position.move_toward(target_position, movement_speed)

	if body.global_position == target_position:
		path_to_travel.pop_front()

	return true
	
func has_path_to_travel() -> bool:
	return not path_to_travel.is_empty()

func set_max_move_distance(value: int) -> void:
	max_move_distance = value
