extends Control

signal ui_station_chosen(station_id)

func _on_station_chosen(station_id):
	emit_signal("ui_station_chosen", station_id)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UIContainer/MarginContainer/HBoxContainer/StationMap.connect("station_chosen",_on_station_chosen)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
