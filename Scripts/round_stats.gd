class_name RoundStats
extends RefCounted

var enemies_undefeated: Dictionary


func add_enemy_undefeated(wave_num: int, enemy: Enemy) -> void:
	if enemies_undefeated.has(wave_num):
		var wave_dict: Dictionary = enemies_undefeated[wave_num] as Dictionary
		if wave_dict.has(enemy):
			wave_dict[enemy] += 1
		else:
			wave_dict[enemy] = 1
	else:
		enemies_undefeated[wave_num] = {}
		enemies_undefeated[wave_num][enemy] = 1
