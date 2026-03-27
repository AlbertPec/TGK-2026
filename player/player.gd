extends Node2D

@export var movement_animation_speed: float = 2.0
@export var max_move_distance: int = -1

var grid_movement := GridMovementController.new()

func _ready() -> void:
	var navigation_provider := _find_navigation_provider()
	if navigation_provider == null:
		push_error("Grid navigation provider not found in group: grid_navigation_provider")
		return

	var floor_layer = navigation_provider.get_floor_layer()
	var walls_layer = navigation_provider.get_walls_layer()
	if floor_layer == null or walls_layer == null:
		push_error("Grid navigation provider returned invalid floor/walls layers")
		return

	grid_movement.setup(
		floor_layer,
		walls_layer,
		movement_animation_speed,
		max_move_distance
	)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move") == false:
		return

	if not grid_movement.has_path_to_travel():
		grid_movement.request_path(global_position, get_global_mouse_position())

func _physics_process(_delta: float) -> void:
	grid_movement.move_body(self)

func _find_navigation_provider() -> GridNavigationProvider:
	var providers = get_tree().get_nodes_in_group(GridNavigationProvider.PROVIDER_GROUP)
	if providers.is_empty():
		return null
	return providers[0] as GridNavigationProvider
