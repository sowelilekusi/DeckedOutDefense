class_name OverclockWeapon extends Weapon


@export var raycast: RayCast3D
@export var range_debug_indicator: CSGSphere3D

var attack_range: float = 0.0
var effect_duration: float = 0.0


func _ready() -> void:
	super._ready()
	attack_range = stats.get_attribute("Range")
	effect_duration = stats.get_attribute("EffectDuration")
	raycast.target_position = Vector3(0, 0, -attack_range)
	range_debug_indicator.radius = attack_range
	raycast.global_position = hero.camera.global_position


func shoot() -> void:
	super.shoot()
	if raycast.is_colliding():
		var target: CharacterBody3D = raycast.get_collider()
		if target != null:
			var target_hitbox: CollisionShape3D = target.shape_owner_get_owner(raycast.get_collider_shape())
			if target_hitbox.get_parent() is TowerBase:
				hit(target, target_hitbox.get_parent())
				#if Data.preferences.display_self_damage_indicators:
					#spawn_damage_indicator(raycast.get_collision_point())
				networked_hit.rpc(get_tree().root.get_path_to(target), get_tree().root.get_path_to(target_hitbox.get_parent()))


func hit(_target: CharacterBody3D, target_hitbox: TowerBase) -> void:
	#target_hitbox.damage(damage)
	if target_hitbox.tower:
		target_hitbox.tower.big_speed_buff_timer += effect_duration


@rpc("reliable")
func networked_hit(target_path: String, target_hitbox_path: String) -> void:
	#var target: CharacterBody3D = get_tree().root.get_node(target_path)
	var target_hitbox: TowerBase = get_tree().root.get_node(target_hitbox_path) as TowerBase
	hit(null, target_hitbox)
	#if Data.preferences.display_party_damage_indicators:
		#spawn_damage_indicator(target.sprite.global_position)
