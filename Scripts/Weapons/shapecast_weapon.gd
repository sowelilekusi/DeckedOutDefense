class_name ShapecastWeapon extends Weapon

@export var shapecast: ShapeCast3D
@export var range_debug_indicator: CSGSphere3D
@export var status_stats: StatusStats
@export var particles: GPUParticles3D

var attack_range: float = 0.0


func _ready() -> void:
	super._ready()
	attack_range = stats.get_attribute("Range")
	range_debug_indicator.radius = attack_range
	shapecast.shape.size.z = attack_range
	shapecast.target_position = -hero.camera.basis.z * (attack_range / 2.0)


func _process(delta: float) -> void:
	super._process(delta)
	particles.emitting = trigger_held


func shoot() -> void:
	super.shoot()
	for index: int in shapecast.get_collision_count():
		var target: CharacterBody3D = shapecast.get_collider(index)
		if target:
			var target_hitbox: Hitbox = target.shape_owner_get_owner(shapecast.get_collider_shape(index))
			if target_hitbox is Hitbox:
				hit(target, target_hitbox)
				if Data.preferences.display_self_damage_indicators:
					spawn_damage_indicator(target.sprite.global_position)
				networked_hit.rpc(get_tree().root.get_path_to(target), get_tree().root.get_path_to(target_hitbox))


func build_status_object() -> StatusEffect:
	var status: StatusEffect = StatusEffect.new()
	status.stats = status_stats
	return status


func hit(target: CharacterBody3D, target_hitbox: Hitbox) -> void:
	target_hitbox.damage(damage)
	target.status_manager.add_effect(build_status_object())


@rpc("reliable")
func networked_hit(target_path: String, target_hitbox_path: String) -> void:
	var target: CharacterBody3D = get_tree().root.get_node(target_path) as CharacterBody3D
	var target_hitbox: Hitbox = get_tree().root.get_node(target_hitbox_path) as Hitbox
	hit(target, target_hitbox)
	if Data.preferences.display_party_damage_indicators:
		spawn_damage_indicator(target.sprite.global_position)
