class_name RadarFeature
extends Feature


func attach_to_tower(tower_stats: CardText) -> void:
	tower_stats.target_type.append(Data.TargetType.AIR)
