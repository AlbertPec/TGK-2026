extends Resource
class_name Attack

@export var display_name: String = "Attack"
@export_range(1, 99, 1) var attack_range: int = 1
@export_range(1, 999, 1) var damage: int = 1
@export var animation_prefix: StringName = &"attack"

func can_target(attacker: Entity, target: Entity) -> bool:
	if attacker == null or target == null:
		return false
	if attacker == target:
		return false
	if not is_instance_valid(attacker) or not is_instance_valid(target):
		return false
	if attacker.is_dead() or target.is_dead():
		return false

	return get_distance_in_tiles(attacker, target) <= attack_range

func get_distance_in_tiles(attacker: Entity, target: Entity) -> int:
	var attacker_cell := attacker.grid_movement.global_to_tile(attacker.global_position)
	var target_cell := target.grid_movement.global_to_tile(target.global_position)
	return maxi(abs(attacker_cell.x - target_cell.x), abs(attacker_cell.y - target_cell.y))

func resolve_animation_name(animation_variant: String) -> StringName:
	return StringName("%s_%s" % [animation_prefix, animation_variant])

func perform(attacker: Entity, target: Entity) -> bool:
	if not can_target(attacker, target):
		return false

	target.take_damage(damage)
	return true
