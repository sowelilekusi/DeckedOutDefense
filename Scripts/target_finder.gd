class_name TargetFinder
extends Node

enum TARGETING_STRATEGY {
	RANDOM = 0,
	MOST_PROGRESSED = 1,
}

@export var tower: Tower
@export var max_targets: int = 1
@export var targeting_strategy: TARGETING_STRATEGY = TARGETING_STRATEGY.MOST_PROGRESSED

#TODO: this was the quantum cache, so uh, maybe thats a godot bug ?
#var multiple_targets_cache: Array[EnemyController]
#var has_target: bool :
	#get:
		#return targets.size() > 0
	#set(_value):
		#return
#
#var targets: Array[EnemyController] :
	#get:
		#return get_multiple_targets()
	#set(_value):
		#return
#
#
#func get_multiple_targets() -> Array[EnemyController]:
	#var new_cache: Array[EnemyController] = []
	#for enemy: EnemyController in multiple_targets_cache:
		#if is_instance_valid(enemy) and enemy.alive and enemy.global_position.distance_to(tower.global_position) <= tower.target_range:
			#new_cache.append(enemy)
	#if max_targets == 0 or new_cache.size() < max_targets:
		#multiple_targets_cache = find_multiple_targets(new_cache)
	#return multiple_targets_cache

var targets: Array[EnemyController] :
	get:
		return find_multiple_targets()
	set(_value):
		return


#func find_multiple_targets(existing_cache: Array[EnemyController]) -> Array[EnemyController]:
func find_multiple_targets() -> Array[EnemyController]:
	var possible_enemies: Array[EnemyController] = []
	for enemy: EnemyController in get_tree().get_nodes_in_group("Enemies"):
		if !is_instance_valid(enemy):
			continue
		if tower.global_position.distance_to(enemy.global_position) > tower.target_range:
			continue
		if !(enemy.stats.target_type & tower.stats.target_type):
			continue
		#if multiple_targets_cache.has(enemy):
		#	continue
		possible_enemies.append(enemy)
	
	#var enemies_to_select: int = max_targets - existing_cache.size()
	var enemies: Array[EnemyController] = [] # temp cache, see above todo
	var enemies_to_select: int = max_targets
	if max_targets == 0:
		enemies_to_select = possible_enemies.size()
	for x: int in enemies_to_select:
		if possible_enemies.size() == 0:
			break
		var chosen: EnemyController = null
		match targeting_strategy:
			TARGETING_STRATEGY.RANDOM:
				chosen = select_random(possible_enemies)
			TARGETING_STRATEGY.MOST_PROGRESSED:
				chosen = select_most_progressed(possible_enemies)
		possible_enemies.erase(chosen)
		#existing_cache.append(chosen)
		enemies.append(chosen)
	
	#return existing_cache
	return enemies


func select_random(choices: Array[EnemyController]) -> EnemyController:
	return choices.pick_random()


func select_most_progressed(choices: Array[EnemyController]) -> EnemyController:
	var most_progressed_enemy: EnemyController = null
	for enemy: EnemyController in choices:
		var em_1: EnemyMovement = enemy.movement_controller as EnemyMovement
		var em_2: EnemyMovement = null
		if most_progressed_enemy != null:
			em_2 = most_progressed_enemy.movement_controller as EnemyMovement
		if (most_progressed_enemy == null or em_1.distance_remaining < em_2.distance_remaining):
			most_progressed_enemy = enemy
	return most_progressed_enemy
