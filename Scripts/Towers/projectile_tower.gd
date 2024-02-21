class_name ProjectileTower extends Tower

@export var projectile_scene: PackedScene

var force: float = 150.0
var projectile_id: int = 0


func shoot() -> void:
	if is_multiplayer_authority():
		networked_spawn_projectile.rpc(multiplayer.get_unique_id())


@rpc("reliable")
func networked_shoot() -> void:
	super.networked_shoot()
	shoot()


@rpc("reliable", "call_local")
func networked_spawn_projectile(peer_id: int) -> Projectile:
	var projectile: Projectile = projectile_scene.instantiate() as Projectile
	projectile.position = yaw_model.global_position
	projectile.damage = damage
	projectile.direction = -yaw_model.global_transform.basis.z
	projectile.force = force
	projectile.name = base_name + str(peer_id) + str(projectile_id)
	get_tree().root.add_child(projectile)
	projectile_id += 1
	return projectile
