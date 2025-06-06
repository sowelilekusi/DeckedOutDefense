class_name WaveManager extends Object
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
	return (20 * number_of_players) + (5 * wave_number)


## Takes in wave number and number of players and returns the amount of coins
## that should be divided between each player after completing the wave
static func calculate_pot(wave_number: int, number_of_players: int) -> int:
	return ceili((2.5 * number_of_players) + (0.5 * wave_number))


## Uses a spawn power budget to "buy" cards of enemies at random selection from
## the given spawn pool, returns the resulting wave but also assigns the cards
## among the given set of enemy spawners
static func generate_wave(spawn_power: int, spawn_pool: Array[Enemy], spawners: Array[EnemySpawner]) -> Wave:
	var wave: Wave = Wave.new()
	
	var points: int = spawn_power / 10.0
	#print("Generating wave with " + str(points) + " points to spend")
	while points > 0:
		var new_card: EnemyCard = EnemyCard.new()
		
		#First, choose an enemy at random
		new_card.enemy = spawn_pool.pick_random()
		
		#Next, we have to figure out if we can actually buy that enemy
		#and, if not, then we have to pick a different enemy, repeat until
		#we've successfully chosen one we can actually afford
		var enemy_chosen: bool = false
		var highest_rarity: Data.Rarity = Data.Rarity.COMMON
		while !enemy_chosen:
			#Next, determine which is the most expensive rarity we can afford
			if new_card.enemy.legendary_cost <= points:
				highest_rarity = Data.Rarity.LEGENDARY
				enemy_chosen = true
			elif new_card.enemy.epic_cost <= points:
				highest_rarity = Data.Rarity.EPIC
				enemy_chosen = true
			elif new_card.enemy.rare_cost <= points:
				highest_rarity = Data.Rarity.RARE
				enemy_chosen = true
			elif new_card.enemy.uncommon_cost <= points:
				highest_rarity = Data.Rarity.UNCOMMON
				enemy_chosen = true
			elif new_card.enemy.common_cost <= points:
				highest_rarity = Data.Rarity.COMMON
				enemy_chosen = true
			else:
				#Even the common rarity was too expensive, so we have to choose
				#a different enemy and try this process again
				var enemy_id: int = spawn_pool.find(new_card.enemy)
				if enemy_id <= 0:
					new_card.enemy = spawn_pool[spawn_pool.size() - 1]
				else:
					new_card.enemy = spawn_pool[enemy_id - 1]
		
		#Now that we know which rarities we could afford, lets just choose a
		#random one
		var chosen_rarity: int = randi_range(0, highest_rarity)
		new_card.rarity = chosen_rarity
		
		#Add that new enemy to the wave and spend the points!
		wave.enemy_groups.append(new_card)
		if chosen_rarity == Data.Rarity.COMMON:
			points -= new_card.enemy.common_cost
		elif chosen_rarity == Data.Rarity.UNCOMMON:
			points -= new_card.enemy.uncommon_cost
		elif chosen_rarity == Data.Rarity.RARE:
			points -= new_card.enemy.rare_cost
		elif chosen_rarity == Data.Rarity.EPIC:
			points -= new_card.enemy.epic_cost
		elif chosen_rarity == Data.Rarity.LEGENDARY:
			points -= new_card.enemy.legendary_cost
	
	var ground_spawners: Array[EnemySpawner] = []
	var air_spawners: Array[EnemySpawner] = []
	for spawner: EnemySpawner in spawners:
		if spawner.type == Data.EnemyType.LAND:
			ground_spawners.append(spawner)
		else:
			air_spawners.append(spawner)
	for card: EnemyCard in wave.enemy_groups:
		if card.enemy.target_type == Data.EnemyType.LAND:
			#TODO: make this use determinisic noise rng
			ground_spawners.pick_random().add_card(card)
		else:
			air_spawners.pick_random().add_card(card)
	return wave
