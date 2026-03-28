extends CharacterBody2D

var astar_grid: AStarGrid2D
@onready var tile_map_floor_layer = $"../MapContainer/Board/Floor"
@onready var tile_map_walls_layer = $"../MapContainer/Board/Walls"
var path_to_travel: Array[Vector2i]

var GRID_SIZE = 16

var MOVEMENT_ANIMATION_SPEED = 2

func _ready() -> void:
	
	var used_tiles = tile_map_floor_layer.get_used_rect()
	
	astar_grid = AStarGrid2D.new()
	var used_rect = tile_map_floor_layer.get_used_rect()

	astar_grid.region = Rect2i(Vector2i.ZERO, used_rect.size)
	astar_grid.cell_size = Vector2(GRID_SIZE, GRID_SIZE)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES # TODO: to discuss
	
	astar_grid.update()
	
	for cell in tile_map_walls_layer.get_used_cells():
		astar_grid.set_point_solid(cell, true)
	
func _input(event):
	if event.is_action_pressed("move") == false:
		return
	
	# path to point clicked
	var start = tile_map_floor_layer.local_to_map(
		tile_map_floor_layer.to_local(global_position)
	)

	var end = tile_map_floor_layer.local_to_map(
		tile_map_floor_layer.to_local(get_global_mouse_position())
	)
	
	var id_path = astar_grid.get_id_path(
		start,
		end
	).slice(1) # [1:]
	
	if id_path.is_empty() == false: # don't move if there is no path
		path_to_travel = id_path
	
func _physics_process(delta: float) -> void: # every physics frame
	if path_to_travel.is_empty():
		return
		
	var target_position = tile_map_floor_layer.to_global(
		tile_map_floor_layer.map_to_local(path_to_travel.front())
	)
	
	global_position = global_position.move_toward(target_position, MOVEMENT_ANIMATION_SPEED)
	
	if global_position == target_position:
		path_to_travel.pop_front()
