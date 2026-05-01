extends Control

@onready var label = $MarginContainer/Panel/MarginContainer/CurrentStationLabel

var station_id_to_name = { # maps id from ui signal to name of station
	"TeatrBagatela":"Teatr Bagatela",
	"DworzecGlowny":"Dworzec Główny",
	"NowyKleparz":"Nowy Kleparz",
}
func change_current_station_label(station_id):
	label.text = "Stacja - " + station_id_to_name[station_id]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
