extends Node2D

@onready var board = $Board
@onready var player = $Player

var entered_train = false
var current_board_scene_path := ""
var board_cache := {}

var station_id_to_path = { # maps id from ui signal to name of map scene
	"TeatrBagatela":"tile_map_teatr_bagatela",
	"DworzecGlowny":"tile_map_dworzec_glowny",
	"NowyKleparz":"tile_map_nowy_kleparz",
}

func change_board(path_to_scene: String):
	if board:
		remove_child(board)

	if board_cache.has(path_to_scene):
		board = board_cache[path_to_scene]
	else:
		board = load(path_to_scene).instantiate()
		board_cache[path_to_scene] = board

	board.name = "Board"
	add_child(board)
	current_board_scene_path = path_to_scene
	
	_connect_board_signal(board)
	await get_tree().process_frame # waits for tree to refresh
	set_player_at_spawn_point()
	player.z_index = 100 # put player above the board - without it, player is invisible

func _connect_board_signal(target_board: Node) -> void:
	var train_entered_callback := Callable(self, "_on_train_entered")
	if not target_board.is_connected("train_entered", train_entered_callback):
		target_board.connect("train_entered", train_entered_callback)

	
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
	current_board_scene_path = board.scene_file_path
	if current_board_scene_path != "":
		board_cache[current_board_scene_path] = board
	_connect_board_signal(board)
	set_player_at_spawn_point()

func _on_hud_ui_station_chosen(station_id: Variant) -> void:
	if entered_train:
		var selected_board_scene_path := "res://board/%s.tscn" % station_id_to_path[station_id]
		if selected_board_scene_path != current_board_scene_path:
			change_board(selected_board_scene_path)
		else:
			set_player_at_spawn_point()
			player.z_index = 100
		entered_train = false
