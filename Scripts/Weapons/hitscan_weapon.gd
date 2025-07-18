class_name HitscanWeapon
extends Weapon

@export var raycast: RayCast3D
@export var range_debug_indicator: CSGSphere3D

var attack_range: float = 0.0


func _ready() -> void:
	super._ready()
	attack_range = stats.get_attribute("Range")
	raycast.target_position = Vector3(0, 0, -attack_range)
	#range_debug_indicator.radius = attack_range
	raycast.global_position = hero.camera.global_position


func shoot() -> void:
	super.shoot()
	if raycast.is_colliding():
		var target: CharacterBody3D = raycast.get_collider()
		if target != null and target is EnemyController:
			var hitbox: Hitbox = target.shape_owner_get_owner(raycast.get_collider_shape())
			hit(hitbox, raycast.get_collision_point())
			networked_hit.rpc(get_tree().root.get_path_to(hitbox), raycast.get_collision_point())


func hit(hitbox: Hitbox, hit_pos: Vector3) -> void:
	hitbox.damage(damage, Data.DamageIndicationType.PLAYER, hit_pos)


@rpc("reliable")
func networked_hit(hitbox_path: String, hit_pos: Vector3) -> void:
	var hitbox: Hitbox = get_tree().root.get_node(hitbox_path) as Hitbox
	hitbox.damage(damage, Data.DamageIndicationType.OTHER_PLAYER, hit_pos)
