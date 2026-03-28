extends Node2D

@onready var map_container = $MapContainer

var current_level
var current_level_name

var level_graph = {
	"tile_map_teatr_bagatela": {
		"left": "tile_map_teatr_bagatela",
		"right": "tile_map_nowy_kleparz"
	},
	"tile_map_nowy_kleparz": {
		"left": "tile_map_teatr_bagatela",
		"right": "tile_map_dworzec_glowny"
	},
	"tile_map_dworzec_glowny": {
		"left": "tile_map_nowy_kleparz",
		"right": "tile_map_dworzec_glowny"
	}
}

func change_map(path_to_scene: String):
	var old_board = map_container.get_node("Board")

	if old_board:
		old_board.queue_free()

	var new_board = load(path_to_scene).instantiate()
	new_board.name = "Board"

	map_container.add_child(new_board)

func _on_level_completed(direction):
	var next_level = level_graph[current_level_name][direction]
	change_map("res://board/%s.tscn" % next_level)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MapContainer.connect("level_completed",_on_level_completed)
	current_level = $MapContainer.get_node("Board");
	current_level_name = "tile_map_nowy_kleparz"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
