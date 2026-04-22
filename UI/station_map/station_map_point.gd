extends VBoxContainer

signal station_selected(station_id)

@export var station_id: String

func _on_pressed():
	emit_signal("station_selected", station_id)

func _ready() -> void:
	$Button.pressed.connect(_on_pressed)
