extends Entity

@export var spawn_grid_cell: Vector2i = Vector2i(-1, -1)
@export var enemy_type: EnemyTypeConfig

@onready var detection_area = $detection_area
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_shape: CollisionShape2D = $detection_area/CollisionShape2D

func _apply_enemy_type_config() -> void:
	if enemy_type == null:
		return

	if enemy_type.sprite_frames != null:
		animated_sprite.sprite_frames = enemy_type.sprite_frames

	if detection_shape.shape is CircleShape2D:
		var area_shape := detection_shape.shape as CircleShape2D
		area_shape.radius = enemy_type.detection_radius

	grid_movement.movement_speed = enemy_type.movement_speed

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
	detection_area.monitoring = true
	
func _physics_process(_delta: float) -> void:
	move_and_update_facing() # to do: do wydzielenia do managera walki
	
	if grid_movement.has_path_to_travel():
		_play_animation(enemy_type.move_animation if enemy_type != null else &"move")
	else:
		_play_animation(enemy_type.idle_animation if enemy_type != null else &"idle")

func on_board_changed() -> void:
	super.on_board_changed()
	spawn(spawn_grid_cell)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("players") or body == null:
		return
	
	# to do: remove when turn system
	var target_cell := grid_movement.global_to_tile(body.global_position)
	grid_movement.move_possible_closest_to(global_position, target_cell)
