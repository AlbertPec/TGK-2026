extends Node2D

@export var switch_id: int

@onready var interactable = $Interactable

signal toggeled_switch(switch_id)

func _on_interacted(interactor = null):
	emit_signal("toggeled_switch", switch_id)

func _ready() -> void:
	interactable.connect("interacted",_on_interacted)
