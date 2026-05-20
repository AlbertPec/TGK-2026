extends Node2D

@onready var repair_puzzle = $RepairPuzzle

signal entered

func _on_interacted(inteructor = null):
	if !GameState.train_puzzle_interacted:
		repair_puzzle.activate_puzzle()
	
	if GameState.train_puzzle_fixed: emit_signal("entered")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Interactable.connect("interacted", _on_interacted)
	
