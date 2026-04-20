extends CharacterBody2D
class_name EnemyBase

@export var movement_speed: float = 2.0
@export var max_move_distance: int = -1
@export var spawn_grid_cell: Vector2i = Vector2i(-1, -1)
@export var auto_chase_on_detection: bool = true

var grid_movement := GridMovementController.new()
var floor_layer: TileMapLayer
var walls_layer: TileMapLayer

func _ready() -> void:
	var navigation_provider := _find_navigation_provider()
	if navigation_provider == null:
		push_error("Grid navigation provider not found in group: grid_navigation_provider")
		return

	setup_grid_movement(navigation_provider)

func _physics_process(_delta: float) -> void:
	grid_movement.move_body(self)

func move_towards(target_global_position: Vector2) -> bool:
	if grid_movement.has_path_to_travel():
		return false
	return grid_movement.request_path(global_position, target_global_position)

func setup_grid_movement(board_node: GridNavigationProvider) -> void:
	floor_layer = board_node.get_floor_layer()
	walls_layer = board_node.get_walls_layer()
	if floor_layer == null or walls_layer == null:
		push_error("Invalid floor/walls layers")
		return

	grid_movement.setup(floor_layer, walls_layer, movement_speed, max_move_distance)
	_apply_spawn_from_grid()

func stop_movement() -> void:
	grid_movement.clear_path()

func start_combat(_player: Node2D) -> void:
	# to-do: combat mechanics
	pass

func _on_detection_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("players"):
		return

	if auto_chase_on_detection:
		move_towards(body.global_position)

	start_combat(body)

func _find_navigation_provider() -> GridNavigationProvider:
	var providers = get_tree().get_nodes_in_group(GridNavigationProvider.PROVIDER_GROUP)
	if providers.is_empty():
		return null
	return providers[0] as GridNavigationProvider

func _apply_spawn_from_grid() -> void:
	if floor_layer == null:
		return
	if spawn_grid_cell.x < 0 or spawn_grid_cell.y < 0:
		return

	global_position = floor_layer.to_global(
		floor_layer.map_to_local(spawn_grid_cell)
	)
