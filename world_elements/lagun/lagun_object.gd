extends Node2D

@onready var interactable = $Interactable

func _on_interacted(interactor = null):
	GlobalSignals.emit_signal("change_textbox_text","To tylko croissant")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.connect("interacted", _on_interacted)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
