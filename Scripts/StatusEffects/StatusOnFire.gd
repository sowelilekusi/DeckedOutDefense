extends StatusEffect
class_name StatusOnFire


func proc():
	affected.damage(stats.potency)
