extends Node2D

@onready var board = $Board
@onready var player = $Player
@onready var turn_mechanism: TurnMechanism = $TurnMechanism

var entered_train = false
var current_board_scene_path := ""
var board_cache := {}

var station_id_to_path = { # maps id from ui signal to name of map scene
	"TeatrBagatela":"tile_map_teatr_bagatela",
	"DworzecGlowny":"tile_map_dworzec_glowny",
	"NowyKleparz":"tile_map_nowy_kleparz",
}

func change_board(path_to_scene: String):
	_end_combat_if_active()

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
	_refresh_fight_connections()
	player.z_index = 100 # put player above the board - without it, player is invisible
	player.can_move = true #movment enabled after leaving the train
	GlobalSignals.emit_signal("change_textbox_text", "player exited the train")
	
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
		GlobalSignals.emit_signal("change_textbox_text","player entered the train")
		player.can_move = false # disable movement becaouse player is in train 
		entered_train = true
		set_player_at_spawn_point()
		player.z_index = -100 # hide player under the board
		player.position = Vector2(-666,-666) # move player over the map

func _ready() -> void:
	current_board_scene_path = board.scene_file_path
	if current_board_scene_path != "":
		board_cache[current_board_scene_path] = board
	_connect_board_signal(board)
	set_player_at_spawn_point()
	_refresh_fight_connections()

func _on_hud_ui_station_chosen(station_id: Variant) -> void:
	if entered_train:
		var selected_board_scene_path := "res://board/%s.tscn" % station_id_to_path[station_id]
		if selected_board_scene_path != current_board_scene_path:
			change_board(selected_board_scene_path)
		else:
			set_player_at_spawn_point()
			player.z_index = 100
		entered_train = false

func _refresh_fight_connections() -> void:
	if turn_mechanism == null:
		return

	turn_mechanism.refresh_entities()
	_connect_fight_signals()

	for node in get_tree().get_nodes_in_group(Entity.ENTITY_GROUP):
		var enemy := node as Enemy
		if enemy == null:
			continue

		var combat_requested_callable := Callable(self, "_on_enemy_combat_requested")
		if not enemy.combat_requested.is_connected(combat_requested_callable):
			enemy.combat_requested.connect(combat_requested_callable)

func _connect_fight_signals() -> void:
	if turn_mechanism == null:
		return

	var combat_started_callable := Callable(self, "_on_combat_started")
	if not turn_mechanism.combat_started.is_connected(combat_started_callable):
		turn_mechanism.combat_started.connect(combat_started_callable)

	var combat_finished_callable := Callable(self, "_on_combat_finished")
	if not turn_mechanism.combat_finished.is_connected(combat_finished_callable):
		turn_mechanism.combat_finished.connect(combat_finished_callable)

func _on_enemy_combat_requested(_enemy: Enemy, _player: Entity) -> void:
	if turn_mechanism == null:
		return
	turn_mechanism.start_combat()

func _on_combat_started() -> void:
	player.stop_movement()
	player.enter_combat()

func _on_combat_finished() -> void:
	player.exit_combat()

func _end_combat_if_active() -> void:
	if turn_mechanism == null:
		return
	if turn_mechanism.combat_active:
		turn_mechanism.end_combat()
