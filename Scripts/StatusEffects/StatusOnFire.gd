extends StatusEffect
class_name StatusOnFire


func proc(affected, stacks, _existing_effects):
	affected.damage(stats.potency * stacks)
