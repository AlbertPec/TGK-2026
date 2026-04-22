extends RefCounted
class_name GridMovementController

var astar_grid: AStarGrid2D
var path_to_travel: Array[Vector2i] = []

var movement_speed: float = 2.0
var max_move_distance: int = -1

var floor_layer: TileMapLayer
var walls_layer: TileMapLayer
var navigation_provider: GridNavigationProvider
var _dynamic_solid_cells: Array[Vector2i] = []
var _occupied_entity_cells := {}

func setup(board_node: GridNavigationProvider):
	navigation_provider = board_node
	floor_layer = board_node.get_floor_layer()
	walls_layer = board_node.get_walls_layer()
	if floor_layer == null or walls_layer == null:
		push_error("Invalid floor/walls layers")
		return

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

	var start := global_to_tile(start_global_position)
	var end := global_to_tile(end_global_position)

	return _set_path(start, end)

func set_move_to(start_global_position: Vector2, target_map_position: Vector2i) -> bool:
	if astar_grid == null or floor_layer == null:
		return false

	var start := global_to_tile(start_global_position)

	return _set_path(start, target_map_position)

func move_possible_closest_to(start_global_position: Vector2, target_map_position: Vector2i) -> bool:
	if astar_grid == null or floor_layer == null:
		return false

	var start := global_to_tile(start_global_position)
	_refresh_dynamic_entity_solids(start)

	if not _occupied_entity_cells.has(target_map_position):
		return _set_path_on_current_grid(start, target_map_position)

	var best_path: Array[Vector2i] = []
	for candidate in _get_adjacent_cells(target_map_position):
		if not astar_grid.is_in_boundsv(candidate):
			continue
		if astar_grid.is_point_solid(candidate):
			continue

		var candidate_path := astar_grid.get_id_path(start, candidate).slice(1)
		if candidate_path.is_empty():
			continue
		if max_move_distance >= 0 and candidate_path.size() > max_move_distance:
			continue

		if best_path.is_empty() or candidate_path.size() < best_path.size():
			best_path = candidate_path

	if best_path.is_empty():
		return false

	path_to_travel = best_path
	return true

func _set_path(start: Vector2i, end: Vector2i) -> bool:
	if astar_grid == null:
		return false

	_refresh_dynamic_entity_solids(start)
	return _set_path_on_current_grid(start, end)

func _set_path_on_current_grid(start: Vector2i, end: Vector2i) -> bool:
	var id_path := astar_grid.get_id_path(start, end).slice(1)
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

	var next_cell := path_to_travel.front() as Vector2i
	if _is_tile_occupied_by_other_entity(next_cell, body):
		clear_path()
		return false

	var target_position = floor_layer.to_global(
		floor_layer.map_to_local(next_cell)
	)
	body.global_position = body.global_position.move_toward(target_position, movement_speed)

	if body.global_position == target_position:
		path_to_travel.pop_front()

	return true
	
func has_path_to_travel() -> bool:
	return not path_to_travel.is_empty()

func set_max_move_distance(value: int) -> void:
	max_move_distance = value
	
func tile_to_global(tile_coords: Vector2i) -> Vector2:
	if floor_layer == null:
		return Vector2.ZERO
	
	var local_pos = floor_layer.map_to_local(tile_coords)
	return floor_layer.to_global(local_pos)

func global_to_tile(global_position: Vector2) -> Vector2i:
	if floor_layer == null:
		return Vector2i.ZERO
	return floor_layer.local_to_map(floor_layer.to_local(global_position))

func _refresh_dynamic_entity_solids(start_cell: Vector2i) -> void:
	if astar_grid == null:
		return

	_clear_dynamic_entity_solids()
	_occupied_entity_cells.clear()

	var tree := _get_navigation_tree()
	if tree == null:
		return

	for node in tree.get_nodes_in_group(Entity.ENTITY_GROUP):
		var entity := node as Node2D
		if entity == null:
			continue

		var entity_cell := global_to_tile(entity.global_position)
		if entity_cell == start_cell:
			continue
		if not astar_grid.is_in_boundsv(entity_cell):
			continue
		if astar_grid.is_point_solid(entity_cell):
			continue

		astar_grid.set_point_solid(entity_cell, true)
		_dynamic_solid_cells.append(entity_cell)
		_occupied_entity_cells[entity_cell] = true

func _clear_dynamic_entity_solids() -> void:
	if astar_grid == null:
		return

	for cell in _dynamic_solid_cells:
		if astar_grid.is_in_boundsv(cell):
			astar_grid.set_point_solid(cell, false)
	_dynamic_solid_cells.clear()

func _is_tile_occupied_by_other_entity(tile: Vector2i, current_body: Node2D) -> bool:
	var tree := _get_navigation_tree()
	if tree == null:
		return false

	for node in tree.get_nodes_in_group(Entity.ENTITY_GROUP):
		var entity := node as Node2D
		if entity == null or entity == current_body:
			continue
		if global_to_tile(entity.global_position) == tile:
			return true
	return false

func _get_navigation_tree() -> SceneTree:
	if navigation_provider == null:
		return null
	if not is_instance_valid(navigation_provider):
		return null
	return navigation_provider.get_tree()

func _get_adjacent_cells(center: Vector2i) -> Array[Vector2i]:
	return [
		center + Vector2i(1, 0),
		center + Vector2i(-1, 0),
		center + Vector2i(0, 1),
		center + Vector2i(0, -1),
		center + Vector2i(1, 1),
		center + Vector2i(1, -1),
		center + Vector2i(-1, 1),
		center + Vector2i(-1, -1),
	]
