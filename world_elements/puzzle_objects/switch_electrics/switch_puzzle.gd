extends Node2D

@onready var switch1 = $Switch1
@onready var switch2 = $Switch2
@onready var switch3 = $Switch3
@onready var switch4 = $Switch4

@onready var light_panel1 = $LightPanel1
@onready var light_panel2 = $LightPanel2
@onready var light_panel3 = $LightPanel3
@onready var light_panel4 = $LightPanel4
@onready var light_panel5 = $LightPanel5
@onready var light_panel6 = $LightPanel6

@onready var doors = $Doors

var switches = []
var lights = []

var switch_light_map = { # correct order -> 3 > 1 > 4 > 3 > 2
	1: [1, 3, 6],        # lewa sekcja
	2: [2, 4],        # środek-lewo
	3: [3, 5],        # środek-prawo
	4: [4, 5, 6]      # prawa sekcja
}

func switch_toggeled(switch_id):
	var affected_lights = switch_light_map[switch_id]

	for light_id in affected_lights:
		var light = lights[light_id-1]

		light.toggle()

	check_puzzle_state()


func check_puzzle_state():
	for light in lights:
		if !light.is_lit:
			close_doors()
			return

	open_doors()


func open_doors():
	print("drzwi otwarte")

	# przykład
	doors.open()


func close_doors():
	print("drzwi zamkniete")

	# przykład
	doors.close()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	switches = [switch1, switch2, switch3, switch4]
	lights = [light_panel1, light_panel2, light_panel3, light_panel4, light_panel5, light_panel6]
	
	for s in switches:
		s.connect("toggeled_switch", switch_toggeled)
		
	# stan początkowy świateł
	light_panel1.off()
	light_panel2.off()
	light_panel3.off()
	light_panel4.on()
	light_panel5.off()
	light_panel6.on()
