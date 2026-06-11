extends Entity
class_name Enemy

@export var spawn_grid_cell: Vector2i = Vector2i(-1, -1)
@export var enemy_type: EnemyTypeConfig

signal combat_requested(enemy: Enemy, player: Entity)

@onready var detection_area = $detection_area
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_shape: CollisionShape2D = $detection_area/CollisionShape2D

var moved_in_turn: bool = false
var player_entity: Entity
var _is_dying: bool = false
var _boar_charge_resolved: bool = false
var _boar_charge_target_reached: bool = false

func _has_detection_area() -> bool:
	return enemy_type.detection_radius > 0.0

func _apply_enemy_type_config() -> void:
	set_max_health(enemy_type.max_health, true)
	animated_sprite.sprite_frames = enemy_type.sprite_frames

	if detection_shape.shape is CircleShape2D:
		detection_shape.shape = detection_shape.shape.duplicate()
		var area_shape := detection_shape.shape as CircleShape2D
		area_shape.radius = enemy_type.detection_radius

	grid_movement.movement_speed = enemy_type.movement_speed
	grid_movement.set_max_move_distance(enemy_type.max_move_distance)
	log_name = enemy_type.display_name
	
	equipped_attack = enemy_type.equipped_attack

func _die() -> void:
	if _is_dead or _is_dying:
		return

	_is_dead = true
	_is_dying = true
	stop_movement()
	_is_performing_attack = false
	_pending_attack_target = null
	_used_attack = false
	_disable_combat_interactions()
	_play_animation(enemy_type.death_animation, true)

	if is_turn_active:
		end_turn()

	await _wait_for_animation_to_finish(enemy_type.death_animation)
	_on_death()

func _play_animation(animation_name: StringName, restart: bool = false) -> bool:
	if animated_sprite.sprite_frames == null:
		return false
	if not animated_sprite.sprite_frames.has_animation(animation_name):
		return false
	if not restart and animated_sprite.animation == animation_name and animated_sprite.is_playing():
		return true
	animated_sprite.play(animation_name)
	return true

func _get_animation_duration(animation_name: StringName) -> float:
	if animated_sprite.sprite_frames == null:
		return 0.0
	if not animated_sprite.sprite_frames.has_animation(animation_name):
		return 0.0

	var animation_speed := animated_sprite.sprite_frames.get_animation_speed(animation_name)
	if animation_speed <= 0.0:
		return 0.0

	var total_duration := 0.0
	for frame_index in animated_sprite.sprite_frames.get_frame_count(animation_name):
		total_duration += animated_sprite.sprite_frames.get_frame_duration(animation_name, frame_index)

	return total_duration / animation_speed

func _wait_for_animation_to_finish(animation_name: StringName) -> void:
	var animation_duration := _get_animation_duration(animation_name)
	if animation_duration <= 0.0:
		return

	var scene_tree := get_tree()
	if scene_tree == null:
		return

	await scene_tree.create_timer(animation_duration).timeout

func _disable_combat_interactions() -> void:
	detection_area.monitoring = false
	detection_area.monitorable = false

	var body_collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if body_collision != null:
		body_collision.disabled = true

	if detection_shape != null:
		detection_shape.disabled = true

func _manage_animations() -> void:
	if _is_dying:
		_play_animation(enemy_type.death_animation)
		return

	if _is_performing_attack:
		_play_animation(enemy_type.attack_animation)
		return

	if grid_movement.has_path_to_travel() and is_turn_active:
		_play_animation(enemy_type.move_animation)
		return

	_play_animation(enemy_type.idle_animation)

func _ready() -> void:
	detection_area.monitoring = false
	detection_area.monitorable = false
	setup_entity()
	z_index = 5
	_apply_enemy_type_config()
	spawn(spawn_grid_cell)
	_resolve_player_entity()
	_on_revived()
	if _has_detection_area():
		detection_area.monitoring = true
		detection_area.monitorable = true

func _on_turn_started(active_entity: Entity) -> void:
	super._on_turn_started(active_entity)
	if active_entity != self:
		return
	if not is_instance_valid(player_entity):
		_resolve_player_entity()

	moved_in_turn = false
	_boar_charge_resolved = false
	_boar_charge_target_reached = false

func _process_turn():
	if _is_dying or _is_performing_attack:
		return

	if not is_instance_valid(player_entity):
		_resolve_player_entity()
	if not is_instance_valid(player_entity):
		end_turn()
		return

	match enemy_type.behaviour:
		"boar":
			_process_boar_turn()
		_:
			_process_default_turn()

func _process_default_turn() -> void:
	if not moved_in_turn:
		var target_cell := grid_movement.global_to_tile(player_entity.global_position)
		grid_movement.move_possible_closest_to(global_position, target_cell)
		moved_in_turn = true

	if moved_in_turn and not grid_movement.has_path_to_travel() and equipped_attack.can_target(self, player_entity):
		request_attack(player_entity)
		return

	if moved_in_turn and not grid_movement.has_path_to_travel() and not equipped_attack.can_target(self, player_entity):
		end_turn()

func _process_boar_turn() -> void:
	if not moved_in_turn:
		if equipped_attack != null and equipped_attack.can_target(self, player_entity):
			request_attack(player_entity)
			return

		_start_boar_charge()
		_boar_charge_resolved = false
		moved_in_turn = true

		if not grid_movement.has_path_to_travel():
			_resolve_boar_charge()
		return

	if grid_movement.has_path_to_travel():
		return

	_resolve_boar_charge()

func _start_boar_charge() -> void:
	var start_cell := grid_movement.global_to_tile(global_position)
	var player_cell := grid_movement.global_to_tile(player_entity.global_position)
	var charge_direction := _get_boar_charge_direction(start_cell, player_cell)
	_boar_charge_target_reached = false

	if charge_direction == Vector2i.ZERO:
		grid_movement.clear_path()
		return

	if grid_movement.astar_grid == null:
		grid_movement.clear_path()
		return

	grid_movement._refresh_dynamic_blocking(start_cell)

	var max_steps := maxi(int(enemy_type.max_move_distance), 0)
	var current_cell := start_cell
	var charge_path: Array[Vector2i] = []

	for _step in range(max_steps):
		var next_cell := current_cell + charge_direction
		if not grid_movement.astar_grid.is_in_boundsv(next_cell):
			break
		if next_cell == player_cell:
			_boar_charge_target_reached = true
			break
		if grid_movement.astar_grid.is_point_solid(next_cell):
			break
		# smarter charge ending
		if charge_direction.y == 0 and player_cell.x == current_cell.x:
			break
		if charge_direction.x == 0 and player_cell.y == current_cell.y:
			break

		charge_path.append(next_cell)
		current_cell = next_cell

	grid_movement.path_to_travel = charge_path

func _get_boar_charge_direction(start_cell: Vector2i, player_cell: Vector2i) -> Vector2i:
	var delta := player_cell - start_cell
	if delta == Vector2i.ZERO:
		return Vector2i.ZERO

	if delta.x == 0:
		return Vector2i(0, 1 if delta.y > 0 else -1)
	if delta.y == 0:
		return Vector2i(1 if delta.x > 0 else -1, 0)

	if abs(delta.x) >= abs(delta.y):
		return Vector2i(1 if delta.x > 0 else -1, 0)
	return Vector2i(0, 1 if delta.y > 0 else -1)

func _resolve_boar_charge() -> void:
	if _boar_charge_resolved:
		return

	_boar_charge_resolved = true

	if _boar_charge_target_reached:
		var attacker_cell := grid_movement.global_to_tile(global_position)
		var player_cell := grid_movement.global_to_tile(player_entity.global_position)
		var attack_distance := grid_movement.attack_distance_between(attacker_cell, player_cell)
		if attack_distance <= equipped_attack.attack_range and attack_distance >= equipped_attack.minimum_attack_range:
			request_attack(player_entity)
			return

	if equipped_attack.can_target(self, player_entity):
		request_attack(player_entity)
		return

	end_turn()

func _resolve_player_entity() -> void:
	var player_nodes := get_tree().get_nodes_in_group("players")
	if player_nodes.is_empty():
		player_entity = null
		return

	player_entity = player_nodes[0] as Entity
	
func _physics_process(_delta: float) -> void:
	if _is_dying:
		_manage_animations()
		return
		
	if is_turn_active:
		_process_turn()

	if grid_movement.has_path_to_travel() and not _is_performing_attack:
		move_and_update_facing()
	_manage_animations()
 

func on_board_changed() -> void:
	super.on_board_changed()
	reset_to_spawn()

func reset_to_spawn() -> void:
	_is_dying = false
	_boar_charge_resolved = false
	_boar_charge_target_reached = false
	restore_full_health()
	spawn(spawn_grid_cell)

func _set_active_state(active: bool) -> void:
	visible = active
	process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	set_physics_process(active)
	set_process_input(active)
	detection_area.monitoring = active and _has_detection_area()
	detection_area.monitorable = active and _has_detection_area()

	var body_collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if body_collision != null:
		body_collision.disabled = not active

	if detection_shape != null:
		detection_shape.disabled = not active or not _has_detection_area()

func _on_death() -> void:
	_is_dying = false
	_set_active_state(false)

func _on_revived() -> void:
	_is_dying = false
	_boar_charge_resolved = false
	_boar_charge_target_reached = false
	_set_active_state(true)
	_manage_animations()

func _finish_attack() -> void:
	if equipped_attack != null and is_instance_valid(_pending_attack_target):
		GlobalSignals.emit_signal("change_textbox_text",
			log_name + " attacked " + _pending_attack_target.log_name + " for " + str(equipped_attack.damage) + " damage")
		equipped_attack.perform(self, _pending_attack_target)

	await _wait_for_animation_to_finish(enemy_type.attack_animation)

	_is_performing_attack = false
	_pending_attack_target = null
	end_turn()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if is_dead():
		return

	if body == null or not body.is_in_group("players"):
		return

	var detected_player := body as Entity
	if detected_player == null:
		return

	combat_requested.emit(self, detected_player)
