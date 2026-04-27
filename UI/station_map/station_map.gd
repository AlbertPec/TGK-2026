extends Control

@onready var CurrentStationLabel = $MarginContainer/Panel/MarginContainer/CurrentStationLabel

signal station_chosen(station_id)

var station_id_to_name = { # maps id from ui signal to name of station
	"TeatrBagatela":"Teatr Bagatela",
	"DworzecGlowny":"Dworzec Główny",
	"NowyKleparz":"Nowy Kleparz",
}

func _on_station_selected(station_id):
	emit_signal("station_chosen", station_id)
	_change_current_station_label(station_id_to_name[station_id])
	
func _change_current_station_label(name):
	CurrentStationLabel.text = "Stacja - " + name

func _ready() -> void:
	for station in $StationsContainer.get_children():
		station.connect("station_selected",_on_station_selected)
