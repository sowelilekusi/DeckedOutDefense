extends ExplosiveProjectile
class_name HomingProjectile

var target : Node3D
@export var acceleration := 40.0
@export var max_speed := 14.0


func _physics_process(_delta: float) -> void:
	if is_instance_valid(target):
		direction = global_position.direction_to(target.global_position)
		#apply_central_force(direction * acceleration)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity += direction * acceleration * state.step
	state.linear_velocity = state.linear_velocity.limit_length(max_speed)
