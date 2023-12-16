extends Area3D
class_name KillBox

@export var level: Level


func _on_body_entered(body: Node3D) -> void:
	body.position = level.player_spawns[0].global_position
