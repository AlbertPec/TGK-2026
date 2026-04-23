extends Entity

@export var movement_animation_speed: float = 2.0
@export var max_move_distance: int = -1
@export var can_move: bool = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var animation_variant = "front"

func _ready() -> void:
	setup_entity()
	grid_movement.set_max_move_distance(-1) # start in idle - have infinite move - todo: change this init

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move") == false or not can_move:
		return

	if not grid_movement.has_path_to_travel():
		grid_movement.request_path(global_position, get_global_mouse_position())

func _calculate_animation_variant() -> void:
	if previous_position == global_position:
		return
	
	if previous_position.x < global_position.x:
		animation_variant = "side"
		return
	if previous_position.y > global_position.y:
		animation_variant = "back"
		return
	animation_variant = "front"
		
func manage_animations() -> void:
	_calculate_animation_variant()
	if grid_movement.has_path_to_travel():
		animated_sprite.play("walk_" + animation_variant)
	else:
		animated_sprite.play("idle_" + animation_variant)
		
func _physics_process(_delta: float) -> void:
	move_and_update_facing()
	manage_animations()
	
