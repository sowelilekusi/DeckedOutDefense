extends Node


func calculate_spawn_power(wave_number : int, number_of_players : int) -> int:
	return 20 + (50 * number_of_players) + (30 * wave_number)


func generate_wave(spawn_power : int, spawn_pool : Array[Enemy]) -> Dictionary:
	var wave = {}
	#var sp_used = 0
	var enemy_types = randi_range(1, 5)
	var enemy_choices = spawn_pool.duplicate()
	var sp_allotment = spawn_power / enemy_types
	for x in enemy_types:
		var choice = enemy_choices.pick_random()
		enemy_choices.erase(choice)
		if sp_allotment / choice.spawn_power > 0:
			wave[choice] = sp_allotment / choice.spawn_power
			#sp_used += wave[choice] * choice.spawn_power
	#print("tried to generate wave with " + str(spawn_power) + " spawn power, used " + str(sp_used))
	return wave
