class_name Ladder extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body is Hero:
		body.movement.enable_climbing()


func _on_body_exited(body: Node3D) -> void:
	if body is Hero:
		body.movement.disable_climbing()
