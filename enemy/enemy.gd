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

func _play_animation(animation_name: StringName) -> void:
	if animated_sprite.sprite_frames == null:
		return
	if not animated_sprite.sprite_frames.has_animation(animation_name):
		return
	animated_sprite.play(animation_name)

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
	if not moved_in_turn:
		var target_cell := grid_movement.global_to_tile(player_entity.global_position)
		grid_movement.move_possible_closest_to(global_position, target_cell)
		moved_in_turn = true
	
	# Pigeons have to move on turn
	if moved_in_turn and not grid_movement.has_path_to_travel() and equipped_attack.can_target(self, player_entity):
		request_attack(player_entity)
	
	if moved_in_turn and not grid_movement.has_path_to_travel() and not equipped_attack.can_target(self, player_entity):
		end_turn()
		
	if moved_in_turn and _used_attack:
		end_turn()

func _resolve_player_entity() -> void:
	var player_nodes := get_tree().get_nodes_in_group("players")
	if player_nodes.is_empty():
		player_entity = null
		return

	player_entity = player_nodes[0] as Entity
	
func _physics_process(_delta: float) -> void:
	if is_dead():
		return
		
	if is_turn_active:
		_process_turn()

	if not grid_movement.has_path_to_travel() or not is_turn_active:
		_play_animation(enemy_type.idle_animation if enemy_type != null else &"idle")
		return

	move_and_update_facing()
	
	if grid_movement.has_path_to_travel():
		_play_animation(enemy_type.move_animation if enemy_type != null else &"move")
	else:
		_play_animation(enemy_type.idle_animation if enemy_type != null else &"idle")
 

func on_board_changed() -> void:
	super.on_board_changed()
	reset_to_spawn()

func reset_to_spawn() -> void:
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
	_set_active_state(false)

func _on_revived() -> void:
	_set_active_state(true)
	_play_animation(enemy_type.idle_animation if enemy_type != null else &"idle")

func _on_detection_area_body_entered(body: Node2D) -> void:
	if is_dead():
		return

	if body == null or not body.is_in_group("players"):
		return

	var detected_player := body as Entity
	if detected_player == null:
		return

	combat_requested.emit(self, detected_player)
