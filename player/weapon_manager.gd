extends Node
class_name WeaponManager

signal unlocked_attacks_changed(unlocked_attacks: Array[Attack])
signal equipped_attack_changed(attack: Attack)
signal attack_unlocked(attack: Attack)

@export var starting_unlocked_attacks: Array[Attack] = []

var player: Player
var _unlocked_attacks: Array[Attack] = []

func _ready() -> void:
	player = get_parent() as Player

	for attack in starting_unlocked_attacks:
		_unlock_attack_internal(attack)

	if player != null and player.equipped_attack != null:
		_unlock_attack_internal(player.equipped_attack)
		equipped_attack_changed.emit(player.equipped_attack)
		unlocked_attacks_changed.emit(get_unlocked_attacks())

func get_unlocked_attacks() -> Array[Attack]:
	return _unlocked_attacks.duplicate()

func unlock_attack(attack: Attack, equip_when_unlocked: bool = false) -> void:
	if not _unlock_attack_internal(attack):
		if equip_when_unlocked:
			equip_attack(attack)
		return

	attack_unlocked.emit(attack)
	unlocked_attacks_changed.emit(get_unlocked_attacks())

	if equip_when_unlocked or player.equipped_attack == null:
		equip_attack(attack)

func equip_attack(attack: Attack) -> bool:
	if player == null or attack == null:
		return false

	var unlocked_attack := _get_unlocked_attack(attack)
	if unlocked_attack == null:
		return false
	if player.equipped_attack == unlocked_attack:
		return true

	player.equipped_attack = unlocked_attack
	equipped_attack_changed.emit(unlocked_attack)
	return true

func is_attack_unlocked(attack: Attack) -> bool:
	return _find_attack_index(attack) != -1

func _unlock_attack_internal(attack: Attack) -> bool:
	if attack == null:
		return false
	if _find_attack_index(attack) != -1:
		return false

	_unlocked_attacks.append(attack)
	return true

func _find_attack_index(attack: Attack) -> int:
	if attack == null:
		return -1

	for index in _unlocked_attacks.size():
		var unlocked_attack := _unlocked_attacks[index]
		if unlocked_attack == attack:
			return index
		if unlocked_attack != null and unlocked_attack.resource_path != "" and unlocked_attack.resource_path == attack.resource_path:
			return index

	return -1

func _get_unlocked_attack(attack: Attack) -> Attack:
	var attack_index := _find_attack_index(attack)
	if attack_index == -1:
		return null
	return _unlocked_attacks[attack_index]
