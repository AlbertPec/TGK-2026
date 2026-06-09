extends Node2D

@onready var interactable = $Interactable


func _on_interacted(interactor = null):
	var player := get_tree().get_nodes_in_group("players")[0] as Player
	player.unlock_attack(preload("res://attack/types/crossbow_attack.tres"), true)
	GlobalSignals.emit_signal("change_textbox_text", "You unlocked crossbow!")

func _ready() -> void:
	interactable.connect("interacted",_on_interacted)
