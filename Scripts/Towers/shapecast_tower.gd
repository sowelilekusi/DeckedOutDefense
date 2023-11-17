extends Tower
class_name ShapecastTower

@export var shapecast : ShapeCast3D
@export var particlesystem : GPUParticles3D
@export var status_stats : StatusStats


func _process(delta: float) -> void:
	super._process(delta)
	if targeted_enemy:
		particlesystem.emitting = true
	else:
		particlesystem.emitting = false


func shoot():
	for index in shapecast.get_collision_count():
		var target = shapecast.get_collider(index) as CharacterBody3D
		hit(target)


func aim():
	yaw_model.look_at(targeted_enemy.global_position)
	pitch_model.look_at(targeted_enemy.global_position)
	pitch_model.rotation.x = 0.0


func hit(target):
	if is_instance_valid(target) and target.alive:
		target.damage(damage)
		if Data.preferences.display_tower_damage_indicators:
			spawn_damage_indicator(target.sprite.global_position)
		target.status_manager.add_effect(build_status_object())
		if is_multiplayer_authority():
			networked_hit.rpc(get_tree().root.get_path_to(target))


func build_status_object() -> StatusEffect:
	var status = StatusEffect.new()
	status.stats = status_stats
	return status


@rpc("reliable")
func networked_hit(target_node_path):
	var target = get_tree().root.get_node(target_node_path)
	hit(target)
