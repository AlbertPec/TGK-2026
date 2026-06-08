extends CharacterBody2D
class_name Entity

const ENTITY_GROUP := "entities"

signal turn_finished(entity: Entity)

@export var visual_node_path: NodePath
@export var facing_right_by_default: bool = true
@export var log_name: String = "unknown name"
@export var equipped_attack: Attack
@export_range(1, 999, 1) var max_health: int = 10

var grid_movement := GridMovementController.new()
var previous_position: Vector2;
var is_turn_active: bool = false
var current_health: int = 0

var _visual_node: Node2D
var _life_initialized: bool = false
var _is_dead: bool = false

var _is_performing_attack: bool = false
var _pending_attack_target: Entity
var _used_attack: bool = false

func setup_entity() -> void:
	if not is_in_group(ENTITY_GROUP):
		add_to_group(ENTITY_GROUP)
	_resolve_visual_node()
	_initialize_life_if_needed()
	setup_navigation()

func _initialize_life_if_needed() -> void:
	if _life_initialized:
		return
	set_max_health(max_health, true)

func set_max_health(value: int, restore_health: bool = false) -> void:
	max_health = maxi(value, 1)

	if restore_health or not _life_initialized:
		current_health = max_health
	else:
		current_health = clampi(current_health, 0, max_health)

	_life_initialized = true
	_is_dead = current_health <= 0

func restore_full_health() -> void:
	current_health = max_health
	var was_dead := _is_dead
	_is_dead = false
	if was_dead:
		_on_revived()

func take_damage(amount: int) -> int:
	if amount <= 0 or is_dead():
		return 0

	var previous_health := current_health
	current_health = maxi(current_health - amount, 0)
	if current_health == 0:
		_die()
	return previous_health - current_health

func heal(amount: int) -> int:
	if amount <= 0 or is_dead():
		return 0

	var previous_health := current_health
	current_health = mini(current_health + amount, max_health)
	return current_health - previous_health

func is_dead() -> bool:
	return _is_dead

func is_alive() -> bool:
	return not is_dead()

func _die() -> void:
	if _is_dead:
		return

	_is_dead = true
	stop_movement()
	_on_death()

func _on_death() -> void:
	print("O nie, nie żyję " + log_name)
	pass

func _on_revived() -> void:
	pass
	
func spawn(spawn_grid_cell: Vector2i) -> void:
	var spawn_global_position = grid_movement.tile_to_global(spawn_grid_cell)
	global_position = spawn_global_position
	previous_position = global_position
	
func spawn_with_marker_and_change_navigation(spawn_marker: Marker2D) -> void:
	global_position = spawn_marker.position
	previous_position = global_position
	setup_navigation()

func setup_navigation() -> bool:
	var navigation_provider := _find_navigation_provider()
	if navigation_provider == null:
		push_error("Grid navigation provider not found in group: grid_navigation_provider")
		return false
	grid_movement.setup(navigation_provider)
	return true

func move_and_update_facing() -> bool:
	previous_position = global_position
	var did_move := grid_movement.move_body(self)
	_update_facing()
	return did_move

func face_towards_position(target_global_position: Vector2) -> void:
	if _visual_node == null:
		return

	var delta_x := target_global_position.x - global_position.x
	if abs(delta_x) < 0.001:
		return

	_apply_horizontal_facing(delta_x > 0.0)

## Attacks

func request_attack(target: Entity) -> bool:
	if equipped_attack != null and equipped_attack.can_target(self, target):
		_start_attack(target)
		return true
	return false

func _start_attack(target: Entity) -> void:
	stop_movement()
	_used_attack = true
	_pending_attack_target = target
	_is_performing_attack = true
	face_towards_position(target.position)
	_finish_attack()

func _finish_attack() -> void:
	if equipped_attack != null and is_instance_valid(_pending_attack_target):
		GlobalSignals.emit_signal("change_textbox_text", 
			self.log_name + " attacked " + _pending_attack_target.log_name + " for " + str(equipped_attack.damage) + " damage")
		equipped_attack.perform(self, _pending_attack_target)

	# wait for attack animation to play
	await get_tree().create_timer(0.5).timeout
	
	_is_performing_attack = false
	_pending_attack_target = null
	end_turn()

##

func _on_turn_started(active_entity: Entity) -> void:
	is_turn_active = active_entity == self
	_is_performing_attack = false
	_pending_attack_target = null
	_used_attack = false

func end_turn() -> void:
	if not is_turn_active:
		return

	is_turn_active = false
	turn_finished.emit(self)

func on_board_changed() -> void:
	stop_movement()
	setup_navigation()

func stop_movement() -> void:
	grid_movement.clear_path()

func finish_current_step_only() -> void:
	grid_movement.keep_only_next_step()

func _find_navigation_provider() -> GridNavigationProvider:
	var providers = get_tree().get_nodes_in_group(GridNavigationProvider.PROVIDER_GROUP)
	if providers.is_empty():
		var provider = get_parent()
		if providers == null or not provider.is_in_group(GridNavigationProvider.PROVIDER_GROUP):
			return provider
			
	return providers[0] as GridNavigationProvider

## visual functions

func _resolve_visual_node() -> void:
	if not visual_node_path.is_empty():
		_visual_node = get_node_or_null(visual_node_path) as Node2D
		return

	_visual_node = get_node_or_null("AnimatedSprite2D") as Node2D
	if _visual_node != null:
		return
	_visual_node = get_node_or_null("Sprite2D") as Node2D

func _update_facing() -> void:
	if _visual_node == null:
		return

	var delta_x := global_position.x - previous_position.x
	if abs(delta_x) < 0.001:
		return

	_apply_horizontal_facing(delta_x > 0.0)

func _apply_horizontal_facing(moving_right: bool) -> void:
	var should_flip := not moving_right if facing_right_by_default else moving_right

	if _visual_node is AnimatedSprite2D:
		(_visual_node as AnimatedSprite2D).flip_h = should_flip
		return

	if _visual_node is Sprite2D:
		(_visual_node as Sprite2D).flip_h = should_flip
		return

	var target_sign := -1.0 if should_flip else 1.0
	_visual_node.scale.x = abs(_visual_node.scale.x) * target_sign
