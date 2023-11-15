extends Weapon
class_name ProjectileWeapon

@export var projectile_scene : PackedScene

var force := 20.0
var projectile_id := 0


func shoot():
	super.shoot()
	networked_spawn_projectile.rpc(multiplayer.get_unique_id(), -global_transform.basis.z)


@rpc("reliable")
func networked_shoot():
	super.networked_shoot()


@rpc("reliable", "call_local")
func networked_spawn_projectile(peer_id, direction):
	var projectile = projectile_scene.instantiate() as Projectile
	projectile.position = global_position
	projectile.damage = damage
	projectile.direction = direction
	projectile.force = force
	projectile.name = str(peer_id) + str(projectile_id)
	get_tree().root.add_child(projectile)
	projectile_id += 1
