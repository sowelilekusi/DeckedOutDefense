class_name DirectAffect extends Affector


func apply_effect(effect: Effect, targets: Array[EnemyController]) -> void:
	for enemy: EnemyController in targets:
		enemy.apply_effect(effect)
		if Data.preferences.display_tower_damage_indicators and effect.damage > 0:
			spawn_damage_indicator(effect.damage, enemy.d_n.global_position)
