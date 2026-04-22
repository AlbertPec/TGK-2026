extends Control

@onready var textbox_container= $TextBoxContainer
@onready var label = $TextBoxContainer/MarginContainer/Label

func clear_textbox():
	label.text = ""
	
func add_text(text):
	label.text = str(text)
