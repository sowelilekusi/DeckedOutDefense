class_name WaveViewer
extends Control

signal closed()

@export var wave_vbox: VBoxContainer
@export var enemy_row_scene: PackedScene


func set_waves(waves: Array[Wave], starting_wave_number: int) -> void:
	var i: int = starting_wave_number
	for wave: Wave in waves:
		var enemy_row: EnemyRow = enemy_row_scene.instantiate() as EnemyRow
		wave_vbox.add_child(enemy_row)
		enemy_row.set_wave(i)
		i += 1
		
		var enemy_dict: Dictionary[Enemy, int] = {}
		
		for group: EnemyCard in wave.enemy_groups:
			if enemy_dict.has(group.enemy):
				enemy_dict[group.enemy] += group_to_count(group)
			else:
				enemy_dict[group.enemy] = group_to_count(group)
		
		for enemy: Enemy in enemy_dict.keys():
			enemy_row.add_enemy_tag(enemy, enemy_dict[enemy])


func group_to_count(group: EnemyCard) -> int:
	var count: int = 0
	if group.rarity == Data.Rarity.COMMON:
		count += group.enemy.common_group
	elif group.rarity == Data.Rarity.UNCOMMON:
		count += group.enemy.uncommon_group
	elif group.rarity == Data.Rarity.RARE:
		count += group.enemy.rare_group
	elif group.rarity == Data.Rarity.EPIC:
		count += group.enemy.epic_group
	elif group.rarity == Data.Rarity.LEGENDARY:
		count += group.enemy.legendary_group
	return count


func _on_button_2_pressed() -> void:
	closed.emit()
	queue_free()
