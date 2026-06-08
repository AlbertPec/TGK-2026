extends Entity
class_name Player

@export var movement_animation_speed: float = 2.0
@export var max_move_distance: int = 4
@export var can_move: bool = true

@onready var PLAYER_LOG_NAME = "player"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var animation_variant = "front"
var in_combat: bool = false
var _preserve_turn_after_forced_move: bool = false
var _move_used_this_turn: bool = false
var _attack_used_this_turn: bool = false


func _ready() -> void:
	setup_entity()
	log_name = PLAYER_LOG_NAME
	grid_movement.set_max_move_distance(-1)

func _on_turn_started(active_entity: Entity) -> void:
	super._on_turn_started(active_entity)
	if active_entity != self:
		return

	_move_used_this_turn = false
	_attack_used_this_turn = false

func _input(event: InputEvent) -> void:
	if not _can_accept_input():
		return
	
	# accept move input
	if event.is_action_pressed("move"):
		if not grid_movement.has_path_to_travel():
			_request_movement_to_mouse()
	
	# accept attack input
	if event.is_action_pressed("attack"):
		if _is_in_combat():
			if _is_performing_attack:
				return

			if _try_attack_from_click():
				return

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
	
func _calculate_combat_animation_variant(target: Entity) -> void:
	if target.position.x > global_position.x or target.position.x < global_position.x:
		animation_variant = "side"
		return
	if target.position.y < global_position.y:
		animation_variant = "back"
		return
	animation_variant = "front"
		
func manage_animations() -> void:
	_calculate_animation_variant()
	if _is_performing_attack:
		_calculate_combat_animation_variant(_pending_attack_target)
		
	if grid_movement.has_path_to_travel():
		animated_sprite.play("walk_" + animation_variant)
	elif _is_performing_attack:
		animated_sprite.play("stab_" + animation_variant)
	else:
		animated_sprite.play("idle_" + animation_variant)
		
func available_actions_left() -> bool:
	if not _is_in_combat():
		return grid_movement.has_path_to_travel()

	if grid_movement.has_path_to_travel():
		return true

	return not _attack_used_this_turn

func _physics_process(_delta: float) -> void:
	if not _is_in_combat():
		if grid_movement.has_path_to_travel():
			move_and_update_facing()
		manage_animations()
		return

	move_and_update_facing()
	manage_animations()
	
	if _preserve_turn_after_forced_move and not grid_movement.has_path_to_travel():
		_preserve_turn_after_forced_move = false
		return

func enter_combat(preserve_turn_after_forced_move: bool = false) -> void:
	in_combat = true
	_preserve_turn_after_forced_move = preserve_turn_after_forced_move
	grid_movement.set_max_move_distance(max_move_distance)

func exit_combat() -> void:
	in_combat = false
	_preserve_turn_after_forced_move = false
	_move_used_this_turn = false
	_attack_used_this_turn = false
	_is_performing_attack = false
	_pending_attack_target = null
	grid_movement.set_max_move_distance(-1)
	is_turn_active = false

func _is_in_combat() -> bool:
	return in_combat

func _can_accept_input() -> bool:
	if not _is_in_combat():
		return true
	return is_turn_active

func _request_movement_to_mouse() -> void:
	if _is_in_combat() and _move_used_this_turn:
		return

	var did_request_path := grid_movement.request_path(global_position, get_global_mouse_position())
	if did_request_path and _is_in_combat():
		_move_used_this_turn = true

func _try_attack_from_click() -> bool:
	if not _is_in_combat():
		return false
	if _attack_used_this_turn:
		return false
	if grid_movement.has_path_to_travel():
		return false

	var clicked_target := _get_enemy_under_mouse()
	if clicked_target == null:
		return false

	var attack_succeded := request_attack(clicked_target)
	if attack_succeded:
		_attack_used_this_turn = true
	return attack_succeded

func _get_enemy_under_mouse() -> Enemy:
	var clicked_cell := grid_movement.global_to_tile(get_global_mouse_position())
	for node in get_tree().get_nodes_in_group(Entity.ENTITY_GROUP):
		var enemy := node as Enemy
		if enemy == null or enemy.is_dead():
			continue
		if grid_movement.global_to_tile(enemy.global_position) == clicked_cell:
			return enemy
	return null
