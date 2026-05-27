extends Control

@onready var textbox_container= $TextBoxContainer
@onready var scroll_container = $TextBoxContainer/MarginContainer/ScrollContainer
@onready var label = $TextBoxContainer/MarginContainer/ScrollContainer/RichTextLabel

func clear_textbox():
	label.text = ""
	
func add_text(text):
	label.text += "\n > %s" % text
