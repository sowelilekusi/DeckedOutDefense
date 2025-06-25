class_name DirectAffect
extends Affector


func apply_effect(effect: Effect, targets: Array[EnemyController]) -> void:
	for enemy: EnemyController in targets:
		enemy.apply_effect(effect)
