extends Node2D
class_name GridNavigationProvider

const PROVIDER_GROUP := "grid_navigation_provider"

@export var floor_layer_path: NodePath = ^"Floor"
@export var walls_layer_path: NodePath = ^"Walls"

func _ready() -> void:
	add_to_group(PROVIDER_GROUP)

func get_floor_layer() -> TileMapLayer:
	return get_node_or_null(floor_layer_path) as TileMapLayer

func get_walls_layer() -> TileMapLayer:
	return get_node_or_null(walls_layer_path) as TileMapLayer
