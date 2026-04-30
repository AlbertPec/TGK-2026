extends VBoxContainer

signal station_selected(station_id)

@onready var button = $Button
@onready var label = $Control/Label

@export var station_id: String
@export var station_name: String

func _on_pressed():
	emit_signal("station_selected", station_id)

func _ready() -> void:
	button.pressed.connect(_on_pressed)
	label.text = station_name
