extends Node2D

@onready var repair_puzzle = $RepairPuzzle

signal entered

func _on_interacted(inteructor = null):
	if !GameState.train_puzzle_interacted:
		GlobalSignals.emit_signal("change_textbox_text","ERROR: jednostka wymaga naprawy\nNiedziałające systemy:\n - silnik trakcyjny\n - system drzwi\n - panel sterowania\n - hamulce\n - zasilanie awaryjne\n Wymienione systemy wymagają natychmiastowej naprawy")
		repair_puzzle.activate_puzzle()
		GameState.train_puzzle_interacted = true
	
	if GameState.train_puzzle_fixed: emit_signal("entered")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Interactable.connect("interacted", _on_interacted)
	
