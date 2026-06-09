extends Control

@onready var health_label: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/HealthLabel
@onready var health_progress_bar: ProgressBar = $MarginContainer/Panel/MarginContainer/VBoxContainer/HealthProgressBar

var player: Player

func bind_to_player(target_player: Player) -> void:
	if target_player == null:
		return

	if player != null:
		var previous_callable := Callable(self, "_on_player_health_changed")
		if player.health_changed.is_connected(previous_callable):
			player.health_changed.disconnect(previous_callable)

	player = target_player
	player.health_changed.connect(_on_player_health_changed)
	_on_player_health_changed(player.current_health, player.max_health)

func _on_player_health_changed(current_health: int, max_health: int) -> void:
	health_label.text = "HP - %d/%d" % [current_health, max_health]
	health_progress_bar.max_value = max_health
	health_progress_bar.value = current_health
