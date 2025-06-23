class_name KillBox
extends Area3D

@export var level: Level


func _on_body_entered(body: Node3D) -> void:
	body.position = level.player_spawns[0].global_position
