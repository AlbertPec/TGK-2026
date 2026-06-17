extends Node2D

@onready var fade = $CanvasLayer/ColorRect
@onready var message_label: Label = $CanvasLayer/MessageLabel

const FADEOUT_GROUP := "fadeout_effect"

var _message_sequence_running: bool = false

func _ready() -> void:
	if not is_in_group(FADEOUT_GROUP):
		add_to_group(FADEOUT_GROUP)
	message_label.visible = false


func fade_in():
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 1.5)
	await tween.finished
	fade.modulate.a = 1.0

func fade_out():
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 1.5)
	await tween.finished

func show_message(message: String, display_time: float = 1.8) -> void:
	if _message_sequence_running:
		return

	_message_sequence_running = true
	message_label.text = message
	message_label.visible = true

	await fade_in()
	await get_tree().create_timer(display_time).timeout
	await fade_out()

	message_label.visible = false
	_message_sequence_running = false
