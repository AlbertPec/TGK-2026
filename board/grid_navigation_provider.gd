extends Node2D
class_name GridNavigationProvider

"""
Abstraction between map and navigation.
"""

const PROVIDER_GROUP := "grid_navigation_provider"

@export var floor_layer_path: NodePath = ^"Floor"
@export var walls_layer_path: NodePath = ^"Walls"


"""
Stations (Levels) change logic.
"""

signal train_entered

func _on_body_entered(body):
	if body.is_in_group("players"):
		emit_signal("train_entered")
		
func _ready() -> void:
	$Train.connect("body_entered", _on_body_entered)
	add_to_group(PROVIDER_GROUP)

func get_floor_layer() -> TileMapLayer:
	return get_node_or_null(floor_layer_path) as TileMapLayer

func get_walls_layer() -> TileMapLayer:
	return get_node_or_null(walls_layer_path) as TileMapLayer
