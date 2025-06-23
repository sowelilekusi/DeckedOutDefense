class_name Health
extends Node

signal health_depleted
signal health_changed(health: int)

@export var damage_particle_scene: PackedScene
@export var max_health: int = 10

var current_health: int


func take_damage(damage: int) -> void:
	current_health -= damage
	health_changed.emit(current_health)
	if current_health <= 0:
		health_depleted.emit()


func heal_damage(healing: int) -> void:
	current_health += healing
	if current_health > max_health:
		current_health = max_health
	health_changed.emit(current_health)
