extends Control

@onready var station_map = $UIContainer/MarginContainer/HBoxContainer/StationMap
@onready var textbox = $UIContainer/MarginContainer/HBoxContainer/Textbox

signal ui_station_chosen(station_id)

func _on_station_chosen(station_id):
	emit_signal("ui_station_chosen", station_id)

func _ready() -> void:
	station_map.connect("station_chosen",_on_station_chosen)
	
	GlobalSignals.change_textbox_text.connect(textbox.add_text)
	GlobalSignals.clear_textbox_text.connect(textbox.clear_textbox)
