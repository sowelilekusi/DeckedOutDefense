extends ExplosiveProjectile
class_name HomingProjectile

var target : Node3D
var acceleration := 50.0
var max_speed := 13.0


func _physics_process(_delta: float) -> void:
	if is_instance_valid(target):
		direction = global_position.direction_to(target.sprite.global_position)
		#apply_central_force(direction * acceleration)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity = state.linear_velocity.limit_length(state.linear_velocity.length() * (1.0 - 0.08))
	state.linear_velocity += direction * acceleration * state.step
	state.linear_velocity = state.linear_velocity.limit_length(max_speed)
