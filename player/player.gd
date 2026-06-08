extends Entity

@export var movement_animation_speed: float = 2.0
@export var max_move_distance: int = 4
@export var can_move: bool = true

@onready var PLAYER_LOG_NAME = "player"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var animation_variant = "front"
var in_combat: bool = false
var _preserve_turn_after_forced_move: bool = false

func _ready() -> void:
	setup_entity()
	log_name = PLAYER_LOG_NAME
	grid_movement.set_max_move_distance(-1)

func _on_turn_started(active_entity: Entity) -> void:
	super._on_turn_started(active_entity)
	if active_entity != self:
		return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move") == false or not can_move:
		return

	if not _can_accept_input():
		return

	if not grid_movement.has_path_to_travel():
		grid_movement.request_path(global_position, get_global_mouse_position())

func _calculate_animation_variant() -> void:
	if previous_position == global_position:
		return
	
	if previous_position.x < global_position.x or previous_position.x > global_position.x:
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
		
func available_actions_left() -> bool:
	return grid_movement.has_path_to_travel() # to-do: change when implemented non-movement actions

func _physics_process(_delta: float) -> void:
	if not _is_in_combat():
		if grid_movement.has_path_to_travel():
			move_and_update_facing()
		manage_animations()
		return

	if not is_turn_active:
		manage_animations()
		return

	var moved = move_and_update_facing()
	manage_animations()
	
	if _preserve_turn_after_forced_move and not grid_movement.has_path_to_travel():
		_preserve_turn_after_forced_move = false
		return

	if not available_actions_left() and moved: # to-do: change when implementing other actions
		end_turn()

func enter_combat(preserve_turn_after_forced_move: bool = false) -> void:
	in_combat = true
	_preserve_turn_after_forced_move = preserve_turn_after_forced_move
	grid_movement.set_max_move_distance(max_move_distance)

func exit_combat() -> void:
	in_combat = false
	_preserve_turn_after_forced_move = false
	grid_movement.set_max_move_distance(-1)
	is_turn_active = false

func _is_in_combat() -> bool:
	return in_combat

func _can_accept_input() -> bool:
	if not _is_in_combat():
		return true
	return is_turn_active
