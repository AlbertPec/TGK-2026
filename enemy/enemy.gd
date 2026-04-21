extends CharacterBody2D

@export var spawn_grid_cell: Vector2i = Vector2i(-1, -1)

var grid_movement := GridMovementController.new()

@onready var detection_area = $detection_area
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _apply_spawn_from_grid() -> void:
	var spawn_global_position = grid_movement.tile_to_global(spawn_grid_cell)
	global_position = spawn_global_position

func _ready() -> void:
	detection_area.monitoring = false
	await get_tree().process_frame
	var navigation_provider := _find_navigation_provider()
	if navigation_provider == null:
		push_error("Grid navigation provider not found in group: grid_navigation_provider")
		return

	grid_movement.setup_grid_movement(navigation_provider)
	_apply_spawn_from_grid()
	grid_movement.movement_speed = 1
	detection_area.monitoring = true
	
func _physics_process(_delta: float) -> void:
	grid_movement.move_body(self) # to do: do wydzielenia do managera walki
	
	if grid_movement.has_path_to_travel():
		animated_sprite.play("move")
	else:
		animated_sprite.play("idle")
	
func _find_navigation_provider() -> GridNavigationProvider:
	var providers = get_tree().get_nodes_in_group(GridNavigationProvider.PROVIDER_GROUP)
	if providers.is_empty():
		return null
	return providers[0] as GridNavigationProvider

func _on_detection_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("players") or body == null:
		return
	
	grid_movement.request_path(global_position, body.global_position)
