extends Node


func calculate_spawn_power(wave_number: int, number_of_players: int) -> int:
	return 20 + (50 * number_of_players) + (30 * wave_number)


func generate_wave(spawn_power: int, spawn_pool: Array[Enemy]) -> Dictionary:
	var wave: Dictionary = {}
	#var sp_used = 0
	var enemy_types: int = randi_range(1, 5)
	var enemy_choices: Array[Enemy] = spawn_pool.duplicate()
	var sp_allotment: int = floori(float(spawn_power) / float(enemy_types))
	for x: int in enemy_types:
		var choice: Enemy = enemy_choices.pick_random()
		enemy_choices.erase(choice)
		if floori(float(sp_allotment) / float(choice.spawn_power)) > 0:
			wave[Data.enemies.find(choice)] = floori(float(sp_allotment) / float(choice.spawn_power))
			#sp_used += wave[Data.enemies.find(choice)] * choice.spawn_power
	#print("Generated wave with spawn power: " + str(sp_used) + "/" + str(spawn_power))
	return wave
