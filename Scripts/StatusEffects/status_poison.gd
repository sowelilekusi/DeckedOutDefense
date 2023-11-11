extends StatusEffect
class_name StatusPoison


func proc(affected, stacks, existing_effects):
	affected.damage(stats.potency * stacks)
