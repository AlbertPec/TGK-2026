extends Area2D

signal reached(direction)

var direction

func _on_body_entered(body):
	emit_signal("reached", direction)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", _on_body_entered)
	if name == "GoalLeft": direction = "left"
	else: direction = "right"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
