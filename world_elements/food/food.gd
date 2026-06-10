extends Node2D

@onready var interactable = $Interactable


func _on_interacted(interactor = null):
	var player := get_tree().get_nodes_in_group("players")[0] as Player
	player.heal(10)
	GlobalSignals.emit_signal("change_textbox_text", "You were healed for 10hp")

func _ready() -> void:
	interactable.connect("interacted",_on_interacted)
