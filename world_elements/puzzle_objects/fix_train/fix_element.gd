extends Node2D

@onready var interactable = $Interactable
@onready var col_box = $Interactable/CollisionShape2D

@export var element_id: int
@export var action_name: String

signal fixed_element(element_id)

func toggle_collision(state: bool):
	col_box.set_deferred("disabled", !state)
	
func _on_interacted(interactor = null):
	fixed_element.emit(element_id)

func _ready() -> void:
	interactable.connect("interacted",_on_interacted)
	interactable.interaction_name = action_name
