class_name StatusSlow
extends StatusEffect


func on_attached(affected: EnemyController, _existing_effects: Dictionary) -> void:
	affected.movement_speed_penalty -= stats.potency


func on_removed(affected: EnemyController, _existing_effects: Dictionary) -> void:
	affected.movement_speed_penalty += stats.potency
