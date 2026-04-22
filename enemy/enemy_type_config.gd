extends Resource
class_name EnemyTypeConfig

@export var display_name: String = "Enemy"
@export var sprite_frames: SpriteFrames
@export var idle_animation: StringName = &"idle"
@export var move_animation: StringName = &"move"
@export var movement_speed: float = 1.0
@export var detection_radius: float = 96.0
