extends Area2D

signal entered(player)

func _on_body_entered(body):
	print("dotkenlo")
	if body.is_in_group("players"):
		emit_signal("entered", body)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered",_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
