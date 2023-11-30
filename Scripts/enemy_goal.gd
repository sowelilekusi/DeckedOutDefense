extends Node3D

@export var audio_player : AudioStreamPlayer3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is EnemyController:
		body.goal_entered()
		audio_player.play()
