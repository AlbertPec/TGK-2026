extends Node2D

@export var note_text: String = ""

@onready var interactable = $Interactable


func _on_interacted(interactor = null):
	GlobalSignals.emit_signal("change_textbox_text", note_text)

func _ready() -> void:
	interactable.connect("interacted",_on_interacted)
