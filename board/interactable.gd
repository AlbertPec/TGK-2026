extends Node

@export var interaction_name: String = ""
@export var is_interactable: bool = true

signal interacted(interactor)

var interact: Callable = func(interactor = null):
	#print("wlazl do pociagu")
	interacted.emit(interactor)
