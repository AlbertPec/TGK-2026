extends Node2D

@onready var interactable = $Interactable

const FADEOUT_GROUP := "fadeout_effect"
const LAGUN_MESSAGE := "To całkiem zwyczajny rogal"

func _on_interacted(interactor = null):
	var fadeout_effect := get_tree().get_first_node_in_group(FADEOUT_GROUP)
	if fadeout_effect != null and fadeout_effect.has_method("show_message"):
		fadeout_effect.show_message(LAGUN_MESSAGE)
		return

	GlobalSignals.emit_signal("change_textbox_text", LAGUN_MESSAGE)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.connect("interacted", _on_interacted)
