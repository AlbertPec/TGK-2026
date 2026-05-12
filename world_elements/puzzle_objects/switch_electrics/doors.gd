class_name Door
extends Node2D

@export var cell: Vector2i

var closed_region = Rect2(128, 128, 32, 32)
var open_region = Rect2(128, 160, 32, 32)

var is_open := false

@onready var sprite = $Sprite2D

func _ready() -> void:
	close()

func open():
	is_open = true
	sprite.region_rect = open_region


func close():
	is_open = false
	sprite.region_rect = closed_region


func toggle():
	if is_open:
		close()
	else:
		open()
