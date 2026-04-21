extends CharacterBody2D
class_name Entity

@export var visual_node_path: NodePath
@export var facing_right_by_default: bool = true

var grid_movement := GridMovementController.new()

var _visual_node: Node2D

func setup_entity() -> void:
	_resolve_visual_node()
	setup_navigation()
	
func spawn(spawn_grid_cell: Vector2i) -> void:
	var spawn_global_position = grid_movement.tile_to_global(spawn_grid_cell)
	global_position = spawn_global_position
	
func spawn_with_marker_and_change_navigation(spawn_marker: Marker2D) -> void:
	global_position = spawn_marker.position
	setup_navigation()

func setup_navigation() -> bool:
	var navigation_provider := _find_navigation_provider()
	grid_movement.setup(navigation_provider)
	if navigation_provider == null:
		push_error("Grid navigation provider not found in group: grid_navigation_provider")
		return false
	return true

func move_and_update_facing() -> bool:
	var previous_position := global_position
	var did_move := grid_movement.move_body(self)
	_update_facing(previous_position)
	return did_move

func stop_movement() -> void:
	grid_movement.clear_path()

func _find_navigation_provider() -> GridNavigationProvider:
	var providers = get_tree().get_nodes_in_group(GridNavigationProvider.PROVIDER_GROUP)
	if providers.is_empty():
		return null
	return providers[0] as GridNavigationProvider

func _resolve_visual_node() -> void:
	if not visual_node_path.is_empty():
		_visual_node = get_node_or_null(visual_node_path) as Node2D
		return

	_visual_node = get_node_or_null("AnimatedSprite2D") as Node2D
	if _visual_node != null:
		return
	_visual_node = get_node_or_null("Sprite2D") as Node2D

func _update_facing(previous_position: Vector2) -> void:
	if _visual_node == null:
		return

	var delta_x := global_position.x - previous_position.x
	if abs(delta_x) < 0.001:
		return

	var moving_right := delta_x > 0.0
	var should_flip := not moving_right if facing_right_by_default else moving_right

	if _visual_node is AnimatedSprite2D:
		(_visual_node as AnimatedSprite2D).flip_h = should_flip
		return

	if _visual_node is Sprite2D:
		(_visual_node as Sprite2D).flip_h = should_flip
		return

	var target_sign := -1.0 if should_flip else 1.0
	_visual_node.scale.x = abs(_visual_node.scale.x) * target_sign
