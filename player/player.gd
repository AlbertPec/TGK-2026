extends CharacterBody2D

@export var movement_animation_speed: float = 2.0
@export var max_move_distance: int = -1
@export var can_move: bool = true

var grid_movement := GridMovementController.new()

func _ready() -> void:
	var navigation_provider := _find_navigation_provider()
	if navigation_provider == null:
		push_error("Grid navigation provider not found in group: grid_navigation_provider")
		return
	
	grid_movement.setup_grid_movement(navigation_provider)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move") == false or not can_move:
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

func stop_movement():
	grid_movement.clear_path()
