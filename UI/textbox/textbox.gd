extends Control

@onready var textbox_container= $TextBoxContainer
@onready var label = $TextBoxContainer/MarginContainer/ScrollContainer/RichTextLabel

func clear_textbox():
	label.text = ""
	
func add_text(text):
	label.text = str(text)
