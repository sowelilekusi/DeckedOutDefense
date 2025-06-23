class_name Affector
extends Node

var damage_particle_scene: PackedScene = preload("res://Scenes/damage_particle.tscn")


@warning_ignore("unused_parameter")
func apply_effect(effect: Effect, targets: Array[EnemyController]) -> void:
	pass


func spawn_damage_indicator(damage: int, pos: Vector3) -> void:
	var marker: Sprite3D = damage_particle_scene.instantiate()
	get_tree().root.add_child(marker)
	marker.set_number(damage)
	marker.position = pos
