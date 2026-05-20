extends Node2D

signal train_fixed

# order:
#1 → 3 → 4 → 2 → 5

var order = [1, 3, 4, 2, 5]
var current_index = 0

@onready var silnik_tarkcyjny = $FixElementSilnikTrakcyjny # 5 
@onready var system_drzwi = $FixElementSystemDrzwi # 4
@onready var zasilanie_awaryjne = $FixElementZasilanieAwaryjne # 1
@onready var hamulce = $FixElementHamulce # 3
@onready var panel_sterowania = $FixElementPaneleSterowania # 2

var fix_elements = []

func disable_object(obj):
	obj.hide()
	obj.toggle_collision(false)
	
func enable_object(obj):
	obj.show()
	obj.toggle_collision(true)
	
func reset_puzzle():
	current_index = 0

	for el in fix_elements:
		enable_object(el)


func fixed_element(element_id):
	if GameState.train_puzzle_fixed:
		return

	# correct element
	if element_id == order[current_index]:

		# disable element
		for el in fix_elements:
			if el.element_id == element_id:
				disable_object(el)
				break

		current_index += 1

		# wsall elements fixed
		if current_index >= order.size():
			GameState.train_puzzle_fixed = true
			GlobalSignals.emit_signal("change_textbox_text","LOG: system w pełni sprawny")

	# zła kolejność
	else:
		GlobalSignals.emit_signal("change_textbox_text","ERROR: błąd systemu")

		reset_puzzle()

	
# -------------------------------

func activate_puzzle():
	GlobalSignals.emit_signal("change_textbox_text","ERROR: jednostka wymaga naprawy\nNiedziałające systemy:\n - silnik trakcyjny\n - system drzwi\n - panel sterowania\n - hamulce\n - zasilanie awaryjne\n Wymienione systemy wymagają natychmiastowej naprawy")
	GameState.train_puzzle_interacted = true
	for el in fix_elements:
		enable_object(el)

func _ready() -> void:
	fix_elements = [silnik_tarkcyjny, system_drzwi, zasilanie_awaryjne, hamulce, panel_sterowania]
	
	for el in fix_elements:
		el.connect("fixed_element",fixed_element)
		disable_object(el)
