extends StatusEffect
class_name StatusPoison


func proc(affected, stacks, _existing_effects):
	affected.damage(stats.potency * stacks)
