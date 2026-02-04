class_name Wave
extends RefCounted


var enemy_groups: Array[EnemyCard]


func to_dict() -> Dictionary:
	var dict: Dictionary = {}
	for group: EnemyCard in enemy_groups:
		var enemy_count: int = 0
		enemy_count = group.count
		if !dict.has(group.enemy.title):
			dict[group.enemy.title] = 0
		dict[group.enemy.title] += enemy_count
	return dict
