extends StatusEffect
class_name StatusCold

func on_attached(affected, existing_effects):
	affected.movement_speed_penalty -= stats.potency


func on_removed(affected, existing_effects):
	affected.movement_speed_penalty += stats.potency
