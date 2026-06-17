extends Node2D

@export var switch_id: int

@onready var interactable = $Interactable
@onready var col_box = $Interactable/CollisionShape2D
@onready var switch_sound_player = $SwitchSoundPlayer

const BLOCKING_GROUP := "blocking_objects"

signal toggeled_switch(switch_id)

func _on_interacted(interactor = null):
	emit_signal("toggeled_switch", switch_id)
	switch_sound_player.play()

func disable_switching():
	col_box.set_deferred("disabled", true)

func _ready() -> void:
	add_to_group(BLOCKING_GROUP)
	interactable.connect("interacted",_on_interacted)
