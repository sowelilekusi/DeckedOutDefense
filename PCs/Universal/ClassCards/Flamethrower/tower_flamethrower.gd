extends Tower
class_name FlameyTower

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
		var status = StatusOnFire.new()
		status.stats = status_stats
		target.status_manager.add_effect(status)


func aim():
	model.look_at(targeted_enemy.global_position)
	model.rotation.x = 0.0
