class_name ExtendedBarrelFeature
extends Feature


func attach_to_tower(tower_stats: CardText) -> void:
	tower_stats.set_attribute("Range", tower_stats.get_attribute("Range") * (1.0 + (strength / 100.0)))
