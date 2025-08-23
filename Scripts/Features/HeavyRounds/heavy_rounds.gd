class_name HeavyRoundsFeature
extends Feature


func attach_to_tower(tower_stats: CardText) -> void:
	tower_stats.set_attribute("Damage", tower_stats.get_attribute("Damage") * (1.0 + (strength / 100.0)))


func attach_to_weapon(weapon_stats: CardText) -> void:
	weapon_stats.set_attribute("Damage", weapon_stats.get_attribute("Damage") * (1.0 + (strength / 100.0)))
