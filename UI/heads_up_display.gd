extends Control

signal ui_station_chosen(station_id)

func _on_station_chosen(station_id):
	emit_signal("ui_station_chosen", station_id)

func _ready() -> void:
	$PanelContainer/HBoxContainer/StationMap.connect("station_chosen",_on_station_chosen)
