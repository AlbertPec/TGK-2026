extends Node2D
class_name AttackTargetOverlay

const FILL_COLOR := Color(0.92, 0.18, 0.18, 0.42)
const OUTLINE_COLOR := Color(1.0, 0.42, 0.42, 0.8)
const RADIUS_SCALE := 0.5
const VERTICAL_OFFSET_SCALE := 0.22
const PULSE_SPEED := 3.2
const PULSE_STRENGTH := 0.08
const OUTLINE_WIDTH := 2.0
const SEGMENT_COUNT := 28

var navigation_provider: GridNavigationProvider
var _targets: Array[Entity] = []
var _pulse_time := 0.0

func _ready() -> void:
	z_index = 1
	set_process(true)

func _process(delta: float) -> void:
	if _targets.is_empty():
		return

	_pulse_time += delta
	queue_redraw()

func set_navigation_provider(provider: GridNavigationProvider) -> void:
	navigation_provider = provider
	queue_redraw()

func set_targets(targets: Array[Entity]) -> void:
	_targets.clear()
	for target in targets:
		if target == null or not is_instance_valid(target):
			continue
		if target.is_dead():
			continue
		_targets.append(target)

	queue_redraw()

func clear() -> void:
	if _targets.is_empty():
		return

	_targets.clear()
	queue_redraw()

func _draw() -> void:
	var floor_layer := _get_floor_layer()
	if floor_layer == null or floor_layer.tile_set == null:
		return
	if _targets.is_empty():
		return

	var tile_size := Vector2(floor_layer.tile_set.tile_size)
	var base_radius := minf(tile_size.x, tile_size.y) * RADIUS_SCALE
	var radius_multiplier := 1.0 + sin(_pulse_time * PULSE_SPEED) * PULSE_STRENGTH
	var radius := base_radius * radius_multiplier
	var offset := Vector2(0.0, tile_size.y * VERTICAL_OFFSET_SCALE)

	for target in _targets:
		if target == null or not is_instance_valid(target):
			continue
		if target.is_dead():
			continue

		var center := to_local(target.global_position + offset)
		var ellipse := _build_ellipse_points(center, radius, radius * 0.62)
		draw_colored_polygon(ellipse, FILL_COLOR)
		draw_polyline(ellipse, OUTLINE_COLOR, OUTLINE_WIDTH, true)

func _build_ellipse_points(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(SEGMENT_COUNT):
		var angle := TAU * float(index) / float(SEGMENT_COUNT)
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	if not points.is_empty():
		points.append(points[0])
	return points

func _get_floor_layer() -> TileMapLayer:
	if navigation_provider == null:
		return null
	if not is_instance_valid(navigation_provider):
		return null
	return navigation_provider.get_floor_layer()
