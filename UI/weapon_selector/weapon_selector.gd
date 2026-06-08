extends Control

@onready var weapon_list: ItemList = $MarginContainer/Panel/MarginContainer/VBoxContainer/WeaponList

var weapon_manager: WeaponManager
var _displayed_attacks: Array[Attack] = []

func bind_to_weapon_manager(target_weapon_manager: WeaponManager) -> void:
	if target_weapon_manager == null:
		return

	if weapon_manager != null:
		var unlocked_callable := Callable(self, "_on_unlocked_attacks_changed")
		var equipped_callable := Callable(self, "_on_equipped_attack_changed")
		if weapon_manager.unlocked_attacks_changed.is_connected(unlocked_callable):
			weapon_manager.unlocked_attacks_changed.disconnect(unlocked_callable)
		if weapon_manager.equipped_attack_changed.is_connected(equipped_callable):
			weapon_manager.equipped_attack_changed.disconnect(equipped_callable)

	weapon_manager = target_weapon_manager
	weapon_manager.unlocked_attacks_changed.connect(_on_unlocked_attacks_changed)
	weapon_manager.equipped_attack_changed.connect(_on_equipped_attack_changed)

	_on_unlocked_attacks_changed(weapon_manager.get_unlocked_attacks())
	_on_equipped_attack_changed(weapon_manager.player.equipped_attack if weapon_manager.player != null else null)

func _ready() -> void:
	weapon_list.item_selected.connect(_on_weapon_selected)

func _on_unlocked_attacks_changed(unlocked_attacks: Array[Attack]) -> void:
	_displayed_attacks = unlocked_attacks
	weapon_list.clear()

	for attack in _displayed_attacks:
		if attack == null:
			continue
		weapon_list.add_item(attack.display_name)

	if weapon_manager != null and weapon_manager.player != null:
		_select_attack(weapon_manager.player.equipped_attack)

func _on_equipped_attack_changed(attack: Attack) -> void:
	_select_attack(attack)

func _on_weapon_selected(index: int) -> void:
	if weapon_manager == null:
		return
	if index < 0 or index >= _displayed_attacks.size():
		return

	weapon_manager.equip_attack(_displayed_attacks[index])

func _select_attack(attack: Attack) -> void:
	weapon_list.deselect_all()

	if attack == null:
		return

	for index in _displayed_attacks.size():
		var displayed_attack := _displayed_attacks[index]
		if displayed_attack == attack:
			weapon_list.select(index)
			weapon_list.ensure_current_is_visible()
			return
		if displayed_attack != null and displayed_attack.resource_path != "" and displayed_attack.resource_path == attack.resource_path:
			weapon_list.select(index)
			weapon_list.ensure_current_is_visible()
			return
