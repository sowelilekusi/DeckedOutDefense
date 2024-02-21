class_name RocketLauncherTower extends ProjectileTower

var target_max: float = 3
var targets: Array = []


func _ready() -> void:
	super._ready()
	target_max = floori(stats.get_attribute("Target Limit"))


func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority():
		#only doing the graphical sort of stuff but not shoot logic 
		if targeted_enemy and is_instance_valid(targeted_enemy):
			if !targeted_enemy.alive or global_position.distance_to(targeted_enemy.global_position) > target_range:
				targeted_enemy = null
			else:
				aim()
		return
	if targets.size() < target_max:
		acquire_target()
	if targets.size() > 0:
		var target_list: Array[EnemyController] = targets.duplicate()
		for target: EnemyController in target_list:
			if !is_instance_valid(target) or !target.alive:
				targets.erase(target)
				continue
			if global_position.distance_to(target.global_position) > target_range:
				targets.erase(target)
		if targets.size() > 0:
			targeted_enemy = targets[0]
			networked_acquire_target.rpc(get_tree().root.get_path_to(targeted_enemy))
			aim()
			if time_since_firing >= time_between_shots:
				time_since_firing -= time_between_shots
				shoot()


func acquire_target() -> void:
	var possible_enemies: Array[EnemyController] = []
	for enemy: EnemyController in get_tree().get_nodes_in_group("Enemies"):
		if global_position.distance_to(enemy.global_position) > target_range:
			continue
		if !(enemy.stats.target_type & stats.target_type):
			continue
		if targets.has(enemy):
			continue
		possible_enemies.append(enemy)
	
	for x: int in target_max - targets.size():
		if possible_enemies.size() == 0:
			return
		var chosen: EnemyController = possible_enemies.pick_random()
		possible_enemies.erase(chosen)
		targets.append(chosen)


func shoot() -> void:
	for target: EnemyController in targets:
		networked_spawn_rocket.rpc(get_tree().root.get_path_to(target), multiplayer.get_unique_id())


@rpc("reliable", "call_local")
func networked_spawn_rocket(target_node_path: String, peer_id: int) -> void:
	var target: EnemyController = get_tree().root.get_node(target_node_path)
	var projectile: RocketProjectile = projectile_scene.instantiate() as RocketProjectile
	projectile.position = global_position + Vector3.UP
	projectile.damage = damage
	projectile.target = target
	projectile.name = base_name + str(peer_id) + str(projectile_id)
	get_tree().root.add_child(projectile)
	projectile.apply_central_impulse(Vector3.UP * 3.0)
	projectile_id += 1
