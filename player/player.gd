extends Entity

@export var movement_animation_speed: float = 2.0
@export var max_move_distance: int = -1
@export var can_move: bool = true

func _ready() -> void:
	setup_entity()
	grid_movement.set_max_move_distance(-1) # start in idle - have infinite move - todo: change this init

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move") == false or not can_move:
		return

	if not grid_movement.has_path_to_travel():
		grid_movement.request_path(global_position, get_global_mouse_position())

func _physics_process(_delta: float) -> void:
	move_and_update_facing()
