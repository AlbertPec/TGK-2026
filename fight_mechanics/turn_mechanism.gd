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

func _ready() -> void:
	refresh_entities()

func refresh_entities() -> void:
	_disconnect_entities()
	_entities = _collect_entities()
	_current_turn_index = _clamp_turn_index(_current_turn_index)

	for entity in _entities:
		var started_callable := Callable(entity, "_on_turn_started")
		if not turn_started.is_connected(started_callable):
			turn_started.connect(started_callable)

		var finished_callable := Callable(self, "_on_entity_turn_finished")
		if not entity.turn_finished.is_connected(finished_callable):
			entity.turn_finished.connect(finished_callable)

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
	for entity in _entities:
		entity._on_turn_started(null)

func _start_current_turn() -> void:
	if _entities.is_empty() or not combat_active:
		_current_entity = null
		_turn_active = false
		return

	_current_turn_index = _clamp_turn_index(_current_turn_index)
	_current_entity = _entities[_current_turn_index]
	turn_started.emit(_current_entity)
	log_turn(_current_entity)

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
