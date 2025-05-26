class_name EnemySpawner extends Node3D

signal enemy_spawned()

@export var land_enemy_scene: PackedScene
@export var leap_enemy_scene: PackedScene
@export var air_enemy_scene: PackedScene
@export var path: VisualizedPath
var astar: AStarGraph3D
@export var own_id: int = 0
@export var type: Data.EnemyType
@export var dest: Node3D
@export var enemy_path: Node

var astar_point_id: int = 0
var enemy_died_callback: Callable
var enemy_reached_goal_callback: Callable
var current_wave: Array[EnemyCard]
var enemy_types_to_spawn: Dictionary = {}
var enemy_spawn_timers: Dictionary = {}
var enemies_spawned: Dictionary = {}
var enemies_to_spawn: int = 0
var done_spawning: bool = true
var enemy_id: int = 0


func _process(delta: float) -> void:
	if enemies_to_spawn == 0:
		done_spawning = true
		return
	
	for x: Enemy in enemy_spawn_timers:
		if enemies_spawned[x] == enemy_types_to_spawn[x]:
			continue
		
		var enemy_stats: Enemy = x
		enemy_spawn_timers[x] += delta
		
		if enemy_spawn_timers[x] >= enemy_stats.spawn_cooldown:
			if is_multiplayer_authority():
				if type == Data.EnemyType.LAND:
					networked_spawn_land_enemy.rpc(Data.enemies.find(enemy_stats), own_id, enemy_id)
				if type == Data.EnemyType.AIR:
					var radius: float = 10.0
					var random_dir: Vector3 = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
					var random_pos: Vector3 = randf_range(0, radius) * random_dir.normalized()
					networked_spawn_air_enemy.rpc(Data.enemies.find(enemy_stats), random_pos, own_id, enemy_id)
			
			enemy_spawn_timers[x] -= enemy_stats.spawn_cooldown
			enemy_spawned.emit()
			enemy_id += 1
			enemies_spawned[x] += 1
			enemies_to_spawn -= 1


#TODO: not sure enemies need all this info over the network
#TODO: generalize enemy scene selection, i.e. store the scenes in the enemy
#card like towers do
@rpc("reliable", "call_local")
func networked_spawn_land_enemy(enemy_stats: int, id1: int, id2: int) -> void:
	var enemy: EnemyController
	if enemy_stats != 6:
		enemy = land_enemy_scene.instantiate() as EnemyController
	else:
		enemy = leap_enemy_scene.instantiate() as EnemyController
	enemy.name = str(id1) + str(id2)
	enemy.stats = Data.enemies[enemy_stats]
	enemy.died.connect(enemy_died_callback)
	enemy.reached_goal.connect(enemy_reached_goal_callback)
	enemy.movement_controller.path = path.curve
	enemy.movement_controller.astar = astar
	enemy.position = global_position
	enemy_path.add_child(enemy)


@rpc("reliable", "call_local")
func networked_spawn_air_enemy(enemy_stats: int, pos: Vector3, id1: int, id2: int) -> void:
	var enemy: EnemyController = air_enemy_scene.instantiate() as EnemyController
	enemy.name = str(id1) + str(id2)
	enemy.position = pos + global_position
	enemy.stats = Data.enemies[enemy_stats]
	enemy.died.connect(enemy_died_callback)
	enemy.reached_goal.connect(enemy_reached_goal_callback)
	enemy.movement_controller.goal = dest
	enemy_path.add_child(enemy)


func spawn_wave() -> void:
	enemies_to_spawn = 0
	enemy_spawn_timers = {}
	for card: EnemyCard in current_wave:
		match(card.rarity):
			Data.Rarity.COMMON:
				enemy_types_to_spawn[card.enemy] += card.enemy.common_group
				enemies_to_spawn += card.enemy.common_group
			Data.Rarity.UNCOMMON:
				enemy_types_to_spawn[card.enemy] += card.enemy.uncommon_group
				enemies_to_spawn += card.enemy.uncommon_group
			Data.Rarity.RARE:
				enemy_types_to_spawn[card.enemy] += card.enemy.rare_group
				enemies_to_spawn += card.enemy.rare_group
			Data.Rarity.EPIC:
				enemy_types_to_spawn[card.enemy] += card.enemy.epic_group
				enemies_to_spawn += card.enemy.epic_group
			Data.Rarity.LEGENDARY:
				enemy_types_to_spawn[card.enemy] += card.enemy.legendary_group
				enemies_to_spawn += card.enemy.legendary_group
		enemy_spawn_timers[card.enemy] = 0.0
		enemies_spawned[card.enemy] = 0
	current_wave = []
	done_spawning = false


func add_card(new_card: EnemyCard) -> void:
	current_wave.append(new_card)
	enemy_types_to_spawn[new_card.enemy] = 0
