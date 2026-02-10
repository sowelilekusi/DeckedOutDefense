class_name EnemyGoal
extends Node3D

signal goal_cleared()
signal goal_occupied()

@export var audio_player: AudioStreamPlayer3D

var enemies_inside: int


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is EnemyController:
		body.goal_entered()
		audio_player.play()


func enemy_entered_shield_range(body: Node3D) -> void:
	if body is EnemyController:
		if enemies_inside == 0:
			goal_occupied.emit()
		enemies_inside += 1
		body.died.connect(enemy_died)
		body.reached_goal.connect(enemy_reached_goal)


func enemy_died(enemy: Enemy) -> void:
	enemies_inside -= 1
	if enemies_inside == 0:
		goal_cleared.emit()


func enemy_reached_goal(enemy: Enemy, penalty: int) -> void:
	enemies_inside -= 1
	if enemies_inside == 0:
		goal_cleared.emit()
