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

@export var next_station: String

signal switch_station(station_name)

func _on_level_changed(body):
	if body.is_in_group("players"):
		print("emituje,signal")
		emit_signal("switch_station", next_station)
		
func _ready() -> void:
	$NextStation.connect("body_entered", _on_level_changed)
	add_to_group(PROVIDER_GROUP)

func get_floor_layer() -> TileMapLayer:
	return get_node_or_null(floor_layer_path) as TileMapLayer

func get_walls_layer() -> TileMapLayer:
	return get_node_or_null(walls_layer_path) as TileMapLayer
