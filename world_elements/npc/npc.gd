extends Node2D

@export_multiline var note_text: String = ""
@export var frames: SpriteFrames
@export var flip_h: bool
@export var cell: Vector2i = Vector2i(-1, -1)

@onready var interactable = $Interactable
@onready var sprite = $AnimatedSprite2D

const BLOCKING_GROUP := "blocking_objects"

func _on_interacted(interactor = null):
	GlobalSignals.emit_signal("change_textbox_text", note_text)

func _ready() -> void:
	if not is_in_group(BLOCKING_GROUP):
		add_to_group(BLOCKING_GROUP)
	sprite.sprite_frames = frames
	interactable.connect("interacted",_on_interacted)
	sprite.play("default")
	sprite.flip_h=flip_h

func get_blocking_cell(grid_movement) -> Vector2i:
	if cell != Vector2i(-1, -1):
		return cell
	return grid_movement.global_to_tile(sprite.global_position)
