class_name RocketLauncherTower extends ProjectileTower


func _ready() -> void:
	super._ready()
	target_finder.max_targets = floori(stats.get_attribute("Target Limit"))


func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority():
		#only doing the graphical sort of stuff but not shoot logic 
		if target_finder.get_multiple_targets().size() >= 1:
			aim()
		return
	if target_finder.get_multiple_targets().size() >= 1:
		#networked_acquire_target.rpc(get_tree().root.get_path_to(targeted_enemy))
		aim()
		if time_since_firing >= time_between_shots:
			time_since_firing -= time_between_shots
			shoot()


func shoot() -> void:
	for target: EnemyController in target_finder.get_multiple_targets():
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
