extends Node
class_name Health

signal health_depleted
signal health_changed(health)

@export var damage_particle_scene : PackedScene

@export var max_health := 10
var current_health

func take_damage(damage):
	current_health -= damage
	health_changed.emit(current_health)
	if current_health <= 0:
		health_depleted.emit()


func heal_damage(healing):
	current_health += healing
	if current_health > max_health:
		current_health = max_health
	health_changed.emit(current_health)
