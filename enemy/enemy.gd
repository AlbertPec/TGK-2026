extends Entity

@export var spawn_grid_cell: Vector2i = Vector2i(-1, -1)
@export var enemy_type: EnemyTypeConfig

@onready var detection_area = $detection_area
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_shape: CollisionShape2D = $detection_area/CollisionShape2D

var player_entity: Entity

func _apply_enemy_type_config() -> void:
	if enemy_type == null:
		return

	if enemy_type.sprite_frames != null:
		animated_sprite.sprite_frames = enemy_type.sprite_frames

	if detection_shape.shape is CircleShape2D:
		var area_shape := detection_shape.shape as CircleShape2D
		area_shape.radius = enemy_type.detection_radius

	grid_movement.movement_speed = enemy_type.movement_speed
	grid_movement.set_max_move_distance(enemy_type.max_move_distance)
	log_name = enemy_type.display_name

func _play_animation(animation_name: StringName) -> void:
	if animated_sprite.sprite_frames == null:
		return
	if not animated_sprite.sprite_frames.has_animation(animation_name):
		return
	animated_sprite.play(animation_name)

func _ready() -> void:
	detection_area.monitoring = false
	setup_entity()
	spawn(spawn_grid_cell)
	_apply_enemy_type_config()
	_resolve_player_entity()
	detection_area.monitoring = true

func _on_turn_started(active_entity: Entity) -> void:
	super._on_turn_started(active_entity)
	if active_entity != self:
		return

	# to-do: move AI to separate place
	var target_cell := grid_movement.global_to_tile(player_entity.global_position)
	grid_movement.move_possible_closest_to(global_position, target_cell)

func _resolve_player_entity() -> void:
	var player_nodes := get_tree().get_nodes_in_group("players")
	if player_nodes.is_empty():
		player_entity = null
		return

	player_entity = player_nodes[0] as Entity
	
func _physics_process(_delta: float) -> void:
	if not is_turn_active:
		_play_animation(enemy_type.idle_animation if enemy_type != null else &"idle")
		return

	if not grid_movement.has_path_to_travel():
		_play_animation(enemy_type.idle_animation if enemy_type != null else &"idle")
		end_turn()
		return

	move_and_update_facing()
	
	if grid_movement.has_path_to_travel():
		_play_animation(enemy_type.move_animation if enemy_type != null else &"move")
	else:
		_play_animation(enemy_type.idle_animation if enemy_type != null else &"idle")
		end_turn() # to-do: change when implemented other fight actions
		 

func on_board_changed() -> void:
	super.on_board_changed()
	spawn(spawn_grid_cell)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("players") or body == null:
		return
