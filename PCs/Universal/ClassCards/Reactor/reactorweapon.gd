extends Weapon

@export var shapecast : ShapeCast3D
@export var particlesystem : GPUParticles3D
@export var status_stats : StatusStats


func _ready() -> void:
	cooldown = 1.0 / stats.fire_rate


func set_raycast_origin(_node):
	pass


func shoot():
	if other_cooldown <= 0 and stats != null:
		other_cooldown = cooldown
		particlesystem.emitting = true
		$AnimationPlayer.play("shoot")
		for index in shapecast.get_collision_count():
			var target = shapecast.get_collider(index) as CharacterBody3D
			var status = StatusRadioactive.new()
			status.stats = status_stats
			target.status_manager.add_effect(status)


func release_trigger():
	trigger_held = false
	particlesystem.emitting = false
