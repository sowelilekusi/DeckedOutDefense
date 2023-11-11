extends StatusEffect
class_name StatusRadioactive

func proc(affected, stacks, existing_effects):
	affected.damage(stats.potency * stacks)
