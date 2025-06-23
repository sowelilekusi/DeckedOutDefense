class_name ProjectileWeapon
extends Weapon

@export var projectile_scene: PackedScene

var force: float = 20.0
var projectile_id: int = 0


func shoot() -> void:
	super.shoot()
	networked_spawn_projectile.rpc(multiplayer.get_unique_id(), -global_transform.basis.z)


@rpc("reliable")
func networked_shoot() -> void:
	super.networked_shoot()


@rpc("reliable", "call_local")
func networked_spawn_projectile(peer_id: int, direction: Vector3) -> void:
	var projectile: Projectile = projectile_scene.instantiate() as Projectile
	projectile.position = global_position
	var effect: Effect = Effect.new()
	effect.damage = damage
	projectile.effect = effect
	projectile.direction = direction
	projectile.force = force
	projectile.owner_id = peer_id
	projectile.name = str(peer_id) + str(projectile_id)
	get_tree().root.add_child(projectile)
	projectile_id += 1
