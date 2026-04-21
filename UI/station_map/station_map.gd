extends Control

signal station_chosen(station_id)

func _on_station_selected(station_id):
	emit_signal("station_chosen", station_id)

func _ready() -> void:
	for station in $StationsContainer.get_children():
		station.connect("station_selected",_on_station_selected)
