extends Node2D

@onready var board = $Board
@onready var player = $Player

func change_board(path_to_scene: String):
	if board:
		board.queue_free()
	board = load(path_to_scene).instantiate()
	board.name = "Board"
	add_child(board)
	board.connect("switch_station", _on_level_changed)
	
	spawn_player()
	
func spawn_player():
	player.stop_movement()
	var spawn = board.get_node("SpawnPoint")
	
	if player.get_parent() == null:
		add_child(player)
	player.global_position = spawn.global_position
	player.z_index = 100
	
	var navigation_provider = board as GridNavigationProvider
	player.setup_grid_movement(navigation_provider)
	
	
func _on_level_changed(station):
	print(station)
	change_board("res://board/%s.tscn" % station)

func _ready() -> void:
	board.connect("switch_station", _on_level_changed)
	spawn_player()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
