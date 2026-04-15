extends Node2D

signal entered

func _on_interacted(inteructor = null):
	print("wlal wlal")
	emit_signal("entered")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Interactable.connect("interacted", _on_interacted)
