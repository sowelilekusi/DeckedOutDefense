extends StatusEffect
class_name StatusDoT


func proc(affected, stacks, _existing_effects):
	affected.damage(stats.potency * stacks)
