class_name EnemyCardUI extends Control

@export var enemy_name: Label
@export var enemy_rarity: TextureRect
@export var enemy_tex: TextureRect
@export var enemy_count: Label


func set_enemy(enemy: EnemyCard) -> void:
	enemy_name.text = enemy.enemy.title
	enemy_rarity.texture.region = Rect2(0.0, 92.0 - (23.0 * int(enemy.rarity)), 124.0, 23.0)
	enemy_tex.texture = enemy.enemy.icon
	if enemy.rarity == Data.Rarity.COMMON:
		enemy_count.text = str(enemy.enemy.common_group)
	elif enemy.rarity == Data.Rarity.UNCOMMON:
		enemy_count.text = str(enemy.enemy.uncommon_group)
	elif enemy.rarity == Data.Rarity.RARE:
		enemy_count.text = str(enemy.enemy.rare_group)
	elif enemy.rarity == Data.Rarity.EPIC:
		enemy_count.text = str(enemy.enemy.epic_group)
	elif enemy.rarity == Data.Rarity.LEGENDARY:
		enemy_count.text = str(enemy.enemy.legendary_group)
