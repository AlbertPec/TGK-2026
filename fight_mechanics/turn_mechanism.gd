extends Node
class_name TurnMechanism

signal turn_started(entity: Entity)
signal turn_finished(entity: Entity)
signal combat_started()
signal combat_finished()

var _entities: Array[Entity] = []
var _current_turn_index: int = -1
var _current_entity: Entity = null
var _turn_active: bool = false
var combat_active: bool = false
var _movement_overlay: MovementRangeOverlay = null

func _ready() -> void:
	refresh_entities()

func refresh_entities() -> void:
	var previous_current_entity := _current_entity
	var current_entity_missing := false

	_disconnect_entities()
	_entities = _collect_entities()
	if _entities.is_empty():
		_current_turn_index = -1
		_current_entity = null
	else:
		if previous_current_entity != null:
			_current_turn_index = _entities.find(previous_current_entity)
			current_entity_missing = _current_turn_index == -1
		_current_turn_index = _clamp_turn_index(_current_turn_index)
		_current_entity = _entities[_current_turn_index]
	_refresh_overlay_provider()

	for entity in _entities:
		var started_callable := Callable(entity, "_on_turn_started")
		if not turn_started.is_connected(started_callable):
			turn_started.connect(started_callable)

		var finished_callable := Callable(self, "_on_entity_turn_finished")
		if not entity.turn_finished.is_connected(finished_callable):
			entity.turn_finished.connect(finished_callable)

	if combat_active and _turn_active:
		if _current_entity == null and not _entities.is_empty():
			_start_current_turn()
		elif current_entity_missing:
			_start_current_turn()
		else:
			_refresh_active_turn_overlay()
	else:
		_clear_movement_overlay()

func start_turn_cycle() -> void:
	if not combat_active:
		return
	if _entities.is_empty():
		_turn_active = false
		_current_entity = null
		_current_turn_index = -1
		return

	_turn_active = true
	_current_turn_index = _clamp_turn_index(_current_turn_index)

	_start_current_turn()

func start_combat() -> void:
	if combat_active:
		return

	combat_active = true
	refresh_entities()
	combat_started.emit()
	start_turn_cycle()

func end_combat() -> void:
	if not combat_active:
		return

	combat_active = false
	reset_turn_cycle()
	combat_finished.emit()

func reset_turn_cycle() -> void:
	_turn_active = false
	_current_turn_index = -1
	_current_entity = null
	_clear_movement_overlay()
	for entity in _entities:
		entity._on_turn_started(null)

func remove_dead_entities():
	for i in range(_entities.size() - 1, -1, -1):
		if _entities[i].is_dead():
			_entities.remove_at(i)

func _start_current_turn() -> void:
	remove_dead_entities()
	if _entities.is_empty() or len(_entities) == 1 or not combat_active:
		_current_entity = null
		_turn_active = false
		end_combat()
		return

	_current_turn_index = _clamp_turn_index(_current_turn_index)
	_current_entity = _entities[_current_turn_index]
	turn_started.emit(_current_entity)
	log_turn(_current_entity)
	_refresh_active_turn_overlay()

func log_turn(entity) -> void:
	GlobalSignals.emit_signal("change_textbox_text", entity.log_name + " turn started")

func _on_entity_turn_finished(entity: Entity) -> void:
	if not _turn_active or not combat_active:
		return
	if entity == null or entity != _current_entity:
		return

	turn_finished.emit(entity)
	_advance_turn()

func _advance_turn() -> void:
	if _entities.is_empty():
		reset_turn_cycle()
		return

	_current_turn_index = (_current_turn_index + 1) % _entities.size()
	_start_current_turn()

func _collect_entities() -> Array[Entity]:
	var collected: Array[Entity] = []
	var tree := get_tree()
	if tree == null:
		return collected

	for node in tree.get_nodes_in_group(Entity.ENTITY_GROUP):
		var entity := node as Entity
		if entity == null:
			continue
		if entity.is_dead():
			continue
		collected.append(entity)

	collected.sort_custom(func(left: Entity, right: Entity) -> bool:
		var left_is_player := left.is_in_group("players")
		var right_is_player := right.is_in_group("players")
		if left_is_player != right_is_player:
			return left_is_player
		return left.get_index() < right.get_index()
	)
	return collected

func _disconnect_entities() -> void:
	for entity in _entities:
		if entity == null:
			continue

		var started_callable := Callable(entity, "_on_turn_started")
		if turn_started.is_connected(started_callable):
			turn_started.disconnect(started_callable)

		var finished_callable := Callable(self, "_on_entity_turn_finished")
		if entity.turn_finished.is_connected(finished_callable):
			entity.turn_finished.disconnect(finished_callable)

		entity._on_turn_started(null)

func _clamp_turn_index(value: int) -> int:
	if value < 0:
		return 0
	if value >= _entities.size():
		return value % _entities.size()
	return value

func _refresh_active_turn_overlay() -> void:
	if not combat_active or _current_entity == null or not _current_entity.is_in_group("players"):
		_clear_movement_overlay()
		return

	_refresh_overlay_provider()
	if _movement_overlay == null:
		return

	var reachable_cells := _current_entity.grid_movement.get_reachable_cells(_current_entity.global_position)
	_movement_overlay.set_player_cells(reachable_cells)

func _clear_movement_overlay() -> void:
	if _movement_overlay == null:
		return
	_movement_overlay.clear()

func _refresh_overlay_provider() -> void:
	var provider := _get_navigation_provider()
	if provider == null:
		_clear_movement_overlay()
		return

	_ensure_movement_overlay()
	if _movement_overlay == null:
		return

	if _movement_overlay.get_parent() != provider:
		var current_parent := _movement_overlay.get_parent()
		if current_parent != null:
			current_parent.remove_child(_movement_overlay)
		provider.add_child(_movement_overlay)

	_movement_overlay.position = Vector2.ZERO
	_movement_overlay.set_navigation_provider(provider)

	var floor_layer := provider.get_floor_layer()
	if floor_layer == null:
		return

	var overlay_index := mini(floor_layer.get_index() + 1, provider.get_child_count() - 1)
	provider.move_child(_movement_overlay, overlay_index)

func _ensure_movement_overlay() -> void:
	if _movement_overlay != null and is_instance_valid(_movement_overlay):
		return

	_movement_overlay = MovementRangeOverlay.new()
	_movement_overlay.name = "MovementRangeOverlay"

func _get_navigation_provider() -> GridNavigationProvider:
	var tree := get_tree()
	if tree == null:
		return null

	var providers := tree.get_nodes_in_group(GridNavigationProvider.PROVIDER_GROUP)
	if providers.is_empty():
		return null

	return providers[0] as GridNavigationProvider
