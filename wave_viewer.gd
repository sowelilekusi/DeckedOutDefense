class_name WaveViewer
extends Control

signal closed()

@export var wave_vbox: VBoxContainer
@export var enemy_row_scene: PackedScene
@export var enemy_icon_tex: TextureRect
@export var enemy_name_label: Label
@export var enemy_desc_label: RichTextLabel


func set_waves(waves: Array[Wave], starting_wave_number: int) -> void:
	var i: int = starting_wave_number
	for wave: Wave in waves:
		var enemy_row: EnemyRow = enemy_row_scene.instantiate() as EnemyRow
		enemy_row.enemy_clicked.connect(set_enemy_desc)
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
	set_enemy_desc(waves[0].enemy_groups[0].enemy)


func group_to_count(group: EnemyCard) -> int:
	var count: int = 0
	count = group.count
	return count


func set_enemy_desc(enemy: Enemy) -> void:
	enemy_name_label.text = tr(enemy.title)
	enemy_icon_tex.texture = enemy.icon
	enemy_desc_label.text = tr(enemy.description)


func _on_button_2_pressed() -> void:
	closed.emit()
	queue_free()
