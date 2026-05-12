extends Node2D

@export var cell: Vector2i
@export var is_lit: bool = false

var open_region = Rect2(0, 0, 32, 32)
var closed_region = Rect2(0, 448, 32, 32)

@onready var sprite = $Sprite2D

func _ready() -> void:
	off()

func on():
	is_lit = true
	sprite.region_rect = open_region


func off():
	is_lit = false
	sprite.region_rect = closed_region


func toggle():
	if is_lit:
		off()
	else:
		on()
