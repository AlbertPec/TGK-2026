extends Resource
class_name Attack

@export var display_name: String = "Attack"
@export_range(1, 99, 1) var attack_range: int = 1
@export_range(1, 99, 1) var minimum_attack_range: int = 1
@export_range(1, 999, 1) var damage: int = 1
@export var attack_animation_name: String = "attack"

func can_target(attacker: Entity, target: Entity) -> bool:
	if attacker == null or target == null:
		return false
	if attacker == target:
		return false
	if not is_instance_valid(attacker) or not is_instance_valid(target):
		return false
	if attacker.is_dead() or target.is_dead():
		return false

	var grid_calculator := attacker.grid_movement
	var distance := grid_calculator.attack_distance_between(
		grid_calculator.local_position(attacker.position), 
		grid_calculator.local_position(target.position))
	return distance <= attack_range and distance >= minimum_attack_range

func perform(attacker: Entity, target: Entity) -> bool:
	if not can_target(attacker, target):
		return false

	target.take_damage(damage)
	return true
