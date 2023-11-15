extends Tower
class_name ProjectileTower

@export var projectile_scene : PackedScene

var force := 2.0
var projectile_id := 0


func shoot():
	if is_multiplayer_authority():
		networked_spawn_projectile.rpc(multiplayer.get_unique_id())


@rpc("reliable")
func networked_shoot():
	super.networked_shoot()
	shoot()


@rpc("reliable", "call_local")
func networked_spawn_projectile(peer_id):
	var projectile = projectile_scene.instantiate() as Projectile
	projectile.position = global_position + Vector3.UP
	projectile.damage = damage
	projectile.direction = -yaw_model.global_transform.basis.z
	projectile.force = force
	projectile.name = base_name + str(peer_id) + str(projectile_id)
	get_tree().root.add_child(projectile)
	projectile_id += 1
