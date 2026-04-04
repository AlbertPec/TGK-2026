extends VBoxContainer

signal station_selected(station_id)

@export var station_id: String

func _on_pressed():
	emit_signal("station_selected", station_id)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Button.pressed.connect(_on_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
