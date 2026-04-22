extends Node2D

@export var note_text: String = ""

@onready var interactable = $Interactable

signal read_note(text)

func interacted():
	emit_signal("read_note", note_text)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.connect("interacted",interacted)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
