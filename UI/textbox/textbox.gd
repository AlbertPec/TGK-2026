extends Control

@onready var textbox_container= $TextBoxContainer
@onready var label = $TextBoxContainer/MarginContainer/HBoxContainer/Label

func clear_textbox():
	label.text = ""
	
func add_text(text):
	label.text = text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
