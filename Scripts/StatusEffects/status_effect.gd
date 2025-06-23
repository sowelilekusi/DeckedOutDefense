class_name StatusEffect
extends Resource

@export var stats: StatusStats

var time_since_proc: float = 0.0
var time_existed: float = 0.0


func on_attached(_affected: EnemyController, _existing_effects: Dictionary) -> void:
	pass


func on_removed(_affected: EnemyController, _existing_effects: Dictionary) -> void:
	pass


func proc(_affected: EnemyController, _stacks: int, _existing_effects: Dictionary) -> void:
	pass
