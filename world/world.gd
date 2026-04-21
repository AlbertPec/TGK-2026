extends Node2D

@onready var board = $Board
@onready var player = $Player

var entered_train = false

var station_id_to_path = { # maps id from ui signal to name of map scene
	"TeatrBagatela":"tile_map_teatr_bagatela",
	"DworzecGlowny":"tile_map_dworzec_glowny",
	"NowyKleparz":"tile_map_nowy_kleparz",
}

func change_board(path_to_scene: String):
	if board:
		board.queue_free()
	board = load(path_to_scene).instantiate()
	board.name = "Board"
	add_child(board)
	
	board.connect("train_entered", _on_train_entered)
	await get_tree().process_frame # waits for tree to refresh
	set_player_at_spawn_point()
	player.z_index = 100 # put player above the board - without it, player is invisible

	
func set_player_at_spawn_point():
	player.stop_movement()
	var spawnpoint = board.get_node("SpawnPoint")
	
	if player.get_parent() == null:
		add_child(player)
	player.spawn_with_marker_and_change_navigation(spawnpoint)
	
func _on_train_entered():
	if not entered_train: 
		entered_train = true
		set_player_at_spawn_point()
		player.z_index = -100 # hide player under the board

func _ready() -> void:
	board.connect("train_entered", _on_train_entered)
	set_player_at_spawn_point()

func _on_hud_ui_station_chosen(station_id: Variant) -> void:
	if entered_train:
		change_board("res://board/%s.tscn" % station_id_to_path[station_id])
		entered_train = false
