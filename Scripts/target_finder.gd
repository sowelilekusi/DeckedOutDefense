class_name TargetFinder extends Node

@export var tower: Tower
@export var max_targets: int = 1

var target_cache: EnemyController
var multiple_targets_cache: Array[EnemyController]


func get_multiple_targets() -> Array[EnemyController]:
	var new_cache: Array[EnemyController] = []
	for enemy: EnemyController in multiple_targets_cache:
		if is_instance_valid(enemy) and enemy.alive and enemy.global_position.distance_to(tower.global_position) <= tower.target_range:
			new_cache.append(enemy)
	if new_cache.size() < max_targets:
		multiple_targets_cache = find_multiple_targets(new_cache)
	return multiple_targets_cache


func get_target() -> EnemyController:
	if !is_instance_valid(target_cache) or !target_cache.alive or tower.global_position.distance_to(target_cache.global_position) > tower.target_range:
		target_cache = find_enemy()
	return target_cache


func find_enemy() -> EnemyController:
	var most_progressed_enemy: EnemyController = null
	for enemy: EnemyController in get_tree().get_nodes_in_group("Enemies"):
		if tower.global_position.distance_to(enemy.global_position) > tower.target_range:
			continue
		var em_1: EnemyMovement = enemy.movement_controller as EnemyMovement
		var em_2: EnemyMovement
		if most_progressed_enemy != null:
			em_2 = most_progressed_enemy.movement_controller as EnemyMovement
		if (most_progressed_enemy == null or em_1.distance_remaining < em_2.distance_remaining) and enemy.stats.target_type & tower.stats.target_type:
			most_progressed_enemy = enemy
	return most_progressed_enemy
	#TODO: Figure out how to multiplayer-ize this
	#networked_acquire_target.rpc(get_tree().root.get_path_to(most_progressed_enemy))


func find_multiple_targets(existing_cache: Array[EnemyController]) -> Array[EnemyController]:
	var possible_enemies: Array[EnemyController] = []
	for enemy: EnemyController in get_tree().get_nodes_in_group("Enemies"):
		if !is_instance_valid(enemy):
			continue
		if tower.global_position.distance_to(enemy.global_position) > tower.target_range:
			continue
		if !(enemy.stats.target_type & tower.stats.target_type):
			continue
		if multiple_targets_cache.has(enemy):
			continue
		possible_enemies.append(enemy)
	
	for x: int in max_targets - existing_cache.size():
		if possible_enemies.size() == 0:
			break
		var chosen: EnemyController = possible_enemies.pick_random()
		possible_enemies.erase(chosen)
		existing_cache.append(chosen)
	
	return existing_cache
