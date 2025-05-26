class_name StatusDoT extends StatusEffect


func proc(affected: EnemyController, stacks: int, _existing_effects: Dictionary) -> void:
	affected.health.take_damage(int(stats.potency * stacks))
