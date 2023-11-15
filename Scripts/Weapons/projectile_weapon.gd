extends Weapon
class_name ProjectileWeapon

@export var projectile_scene : PackedScene

var force := 2.0
var projectile_id := 0


func shoot():
	super.shoot()
	var projectile = projectile_scene.instantiate() as Projectile
	projectile.position = global_position
	projectile.damage = damage
	projectile.direction = -global_transform.basis.z
	projectile.force = force
	projectile.name = str(multiplayer.get_unique_id()) + str(projectile_id)
	get_tree().root.add_child(projectile)
	projectile_id += 1


@rpc("reliable")
func networked_shoot():
	super.networked_shoot()
	shoot()
