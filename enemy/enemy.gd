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

func _apply_enemy_type_config() -> void:
	if enemy_type == null:
		return

	set_max_health(enemy_type.max_health, true)

	if enemy_type.sprite_frames != null:
		animated_sprite.sprite_frames = enemy_type.sprite_frames

	if detection_shape.shape is CircleShape2D:
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
	_manage_animations()

	if is_turn_active:
		end_turn()

	if not enemy_type.behaviour == "pigeon": # hack to fix pigeon lack of animation
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
		_play_animation(enemy_type.move_animation if enemy_type != null else &"move")
		return

	_play_animation(enemy_type.idle_animation if enemy_type != null else &"idle")

func _ready() -> void:
	detection_area.monitoring = false
	setup_entity()
	z_index = 5
	_apply_enemy_type_config()
	spawn(spawn_grid_cell)
	_resolve_player_entity()
	_on_revived()
	detection_area.monitoring = true

func _on_turn_started(active_entity: Entity) -> void:
	super._on_turn_started(active_entity)
	if active_entity != self:
		return
	if not is_instance_valid(player_entity):
		_resolve_player_entity()

	moved_in_turn = false

func _process_turn():
	if _is_dying or _is_performing_attack:
		return

	if not moved_in_turn:
		var target_cell := grid_movement.global_to_tile(player_entity.global_position)
		grid_movement.move_possible_closest_to(global_position, target_cell)
		moved_in_turn = true
	
	if enemy_type.behaviour == "pigeon" or enemy_type.behaviour == "boar":
		# Pigeons have to move on turn
		if moved_in_turn and not grid_movement.has_path_to_travel() and equipped_attack.can_target(self, player_entity):
			request_attack(player_entity)
			return
		
		if moved_in_turn and not grid_movement.has_path_to_travel() and not equipped_attack.can_target(self, player_entity):
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

	move_and_update_facing()
	_manage_animations()
 

func on_board_changed() -> void:
	super.on_board_changed()
	reset_to_spawn()

func reset_to_spawn() -> void:
	_is_dying = false
	restore_full_health()
	spawn(spawn_grid_cell)

func _set_active_state(active: bool) -> void:
	visible = active
	process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	set_physics_process(active)
	set_process_input(active)
	detection_area.monitoring = active
	detection_area.monitorable = active

	var body_collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if body_collision != null:
		body_collision.disabled = not active

	if detection_shape != null:
		detection_shape.disabled = not active

func _on_death() -> void:
	_is_dying = false
	_set_active_state(false)

func _on_revived() -> void:
	_is_dying = false
	_set_active_state(true)
	_manage_animations()

func _finish_attack() -> void:
	if equipped_attack != null and is_instance_valid(_pending_attack_target):
		GlobalSignals.emit_signal("change_textbox_text",
			log_name + " attacked " + _pending_attack_target.log_name + " for " + str(equipped_attack.damage) + " damage")
		equipped_attack.perform(self, _pending_attack_target)

	var scene_tree := get_tree()
	if scene_tree == null:
		_is_performing_attack = false
		_pending_attack_target = null
		return

	var attack_duration := _get_animation_duration(enemy_type.attack_animation)
	if attack_duration <= 0.0:
		attack_duration = 0.5

	await scene_tree.create_timer(attack_duration).timeout

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
