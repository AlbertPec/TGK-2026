extends Resource
class_name EnemyTypeConfig

@export var display_name: String = "Enemy"
@export var behaviour: String = "pigeon"
@export var sprite_frames: SpriteFrames
@export var idle_animation: StringName = &"idle"
@export var move_animation: StringName = &"move"
@export var attack_animation: StringName = &"attack"
@export var death_animation: StringName = &"idle"
@export var movement_speed: float = 1.0
@export var detection_radius: float = 96.0
@export var max_move_distance: float = 3
@export var equipped_attack: Attack
@export_range(1, 999, 1) var max_health: int = 1
