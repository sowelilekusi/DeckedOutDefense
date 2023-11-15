extends StatusEffect
class_name StatusSlow


func on_attached(affected, _existing_effects):
	affected.movement_speed_penalty -= stats.potency


func on_removed(affected, _existing_effects):
	affected.movement_speed_penalty += stats.potency
