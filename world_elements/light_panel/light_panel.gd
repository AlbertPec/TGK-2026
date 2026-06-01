extends Node2D

@export var cell: Vector2i
@export var is_lit: bool = false


@onready var sprite = $Sprite2D

func _ready() -> void:
	if is_lit:
		on()
	else:
		off()

func on():
	is_lit = true
	$Sprite2D.modulate = Color(1.2, 0.729, 0.701, 1.0)


func off():
	is_lit = false
	$Sprite2D.modulate = Color.WHITE


func toggle():
	if is_lit:
		off()
	else:
		on()
