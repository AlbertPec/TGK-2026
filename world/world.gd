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
	set_player_at_spawn_point()
	player.z_index = 100 # put player above the board - without it, player cis invisible

	
func set_player_at_spawn_point():
	player.stop_movement()
	var spawn = board.get_node("SpawnPoint")
	
	if player.get_parent() == null:
		add_child(player)
	player.global_position = spawn.global_position
	
	var navigation_provider = board as GridNavigationProvider
	player.setup_grid_movement(navigation_provider)
	
func _on_train_entered():
	print("git")
	if not entered_train: 
		entered_train = true
		set_player_at_spawn_point()
		player.z_index = -100 # hide player under the board

func _ready() -> void:
	board.connect("train_entered", _on_train_entered)
	set_player_at_spawn_point()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_hud_ui_station_chosen(station_id: Variant) -> void:
	if entered_train:
		change_board("res://board/%s.tscn" % station_id_to_path[station_id])
		entered_train = false
