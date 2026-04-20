extends EnemyBase

@export var move_animation_name: StringName = &"move"
@export var idle_animation_name: StringName = &"idle"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super()
	if animated_sprite == null:
		push_error("Enemy needs to have animated sprite")
	
	animated_sprite.play(move_animation_name)
