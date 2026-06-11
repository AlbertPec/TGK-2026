extends Node2D

@onready var fade = $CanvasLayer/ColorRect


func fade_in():
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 1.5)
	await tween.finished
	fade.modulate.a = 1.0

func fade_out():
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 1.5)
	await tween.finished
