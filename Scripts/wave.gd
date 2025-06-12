class_name Wave extends RefCounted


var enemy_groups: Array[EnemyCard]


func to_dict() -> Dictionary:
	var dict: Dictionary = {}
	for group: EnemyCard in enemy_groups:
		var enemy_count: int = 0
		if group.rarity == Data.Rarity.COMMON:
			enemy_count = group.enemy.common_group
		elif group.rarity == Data.Rarity.UNCOMMON:
			enemy_count = group.enemy.uncommon_group
		elif group.rarity == Data.Rarity.RARE:
			enemy_count = group.enemy.rare_group
		elif group.rarity == Data.Rarity.EPIC:
			enemy_count = group.enemy.epic_group
		elif group.rarity == Data.Rarity.LEGENDARY:
			enemy_count = group.enemy.legendary_group
		if !dict.has(group.enemy.title):
			dict[group.enemy.title] = 0
		dict[group.enemy.title] += enemy_count
	return dict
