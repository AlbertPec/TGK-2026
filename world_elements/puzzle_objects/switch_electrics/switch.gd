extends Node2D

@export var switch_id: int

@onready var interactable = $Interactable

const BLOCKING_GROUP := "blocking_objects"

signal toggeled_switch(switch_id)

func _on_interacted(interactor = null):
	emit_signal("toggeled_switch", switch_id)

func _ready() -> void:
	add_to_group(BLOCKING_GROUP)
	interactable.connect("interacted",_on_interacted)
