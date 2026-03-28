extends Node2D

signal level_completed(next_level_path)

func _ready():
	$GoalLeft.connect("reached", _on_goal_reached)
	$GoalRight.connect("reached", _on_goal_reached)

func _on_goal_reached(direction):
	emit_signal("level_completed", direction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
