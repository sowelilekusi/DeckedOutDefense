class_name WaveManager
extends Object
## A collection of static functions related to enemy wave generation
##
## Contains the algorithm for generating a wave based on a given pool of enemies
## as well as the functions for determining how much powerful a given enemy wave
## should be based on the the number of players and what number wave it is.
##
## Also contains the function for determining how much money is earned after
## completing a wave


## Takes in wave number and number of players and returns a spawn power value
## intended for passing into the generate_wave method
static func calculate_spawn_power(wave_number: int, number_of_players: int) -> int:
	#print("wave number: " + str(wave_number) + ", number of players: " + str(number_of_players))
	return (11 * number_of_players) + (6 * wave_number)


## Takes in wave number and number of players and returns the amount of coins
## that should be divided between each player after completing the wave
static func calculate_pot(wave_number: int, number_of_players: int) -> int:
	return ceili((3.0 * number_of_players) + (2.5 * wave_number))


static func get_test_wave(spawn_pool: Array[Enemy]) -> Wave:
	var wave: Wave = Wave.new()
	for x: int in 3:
		var new_card: EnemyCard = EnemyCard.new()
		new_card.enemy = spawn_pool[0]
		new_card.rarity = Data.Rarity.COMMON
		wave.enemy_groups.append(new_card)
	return wave


## Uses a spawn power budget to "buy" cards of enemies at random selection from
## the given spawn pool, returns the resulting wave but also assigns the cards
## among the given set of enemy spawners
static func generate_wave(spawn_power: int, spawn_pool: Array[Enemy]) -> Wave:
	var wave: Wave = Wave.new()
	
	#print("Generating wave with " + str(points) + " points to spend")
	while spawn_power > 0:
		var new_card: EnemyCard = EnemyCard.new()
		
		#First, choose an enemy at random
		new_card.enemy = spawn_pool[NoiseRandom.randi_in_range(spawn_power, 0, spawn_pool.size() - 1)]
		
		#Next, we have to figure out if we can actually buy that enemy
		#and, if not, then we have to pick a different enemy, repeat until
		#we've successfully chosen one we can actually afford
		var enemy_chosen: bool = false
		var most_enemies_afforded: int = 0
		var first_enemy_id: int = -1
		while !enemy_chosen:
			#Next, determine what is the most groups we can afford
			most_enemies_afforded = int(spawn_power / new_card.enemy.spawn_power)
			if most_enemies_afforded > 0:
				enemy_chosen = true
			else:
				#Even 1 group was too expensive, so we have to choose
				#a different enemy and try this process again
				var enemy_id: int = spawn_pool.find(new_card.enemy)
				enemy_id -= 1
				if first_enemy_id == -1:
					first_enemy_id = enemy_id
				if enemy_id < 0:
					new_card.enemy = spawn_pool[spawn_pool.size() - 1]
				else:
					new_card.enemy = spawn_pool[enemy_id]
				most_enemies_afforded = 0
				if enemy_id == first_enemy_id:
					return wave
		#Now that we know how many we could afford, lets just choose a
		#random number of groups
		var chosen_groups: int = NoiseRandom.randi_in_range(spawn_power, 1, most_enemies_afforded)
		new_card.count = chosen_groups * new_card.enemy.group_size
		
		#Add that new enemy to the wave and spend the points!
		wave.enemy_groups.append(new_card)
		spawn_power -= chosen_groups * new_card.enemy.spawn_power
	return wave
