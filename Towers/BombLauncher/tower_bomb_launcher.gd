class_name BombLauncherTower extends Tower


func _ready() -> void:
	super._ready()
	#TODO: this needs a getter/setter on target_range to make sure force is
	#recalculated if target_range changes
	affector.force = sqrt((target_range * ProjectSettings.get_setting("physics/3d/default_gravity")) / sin(2 * 45))


func aim() -> void:
	super.aim()
	var pos: Vector2 = Vector2(global_position.x, global_position.z)
	var t_pos: Vector2 = Vector2(target_finder.targets[0].global_position.x, target_finder.targets[0].global_position.z)
	var x: float = pos.distance_to(t_pos)
	var y: float = target_finder.targets[0].global_position.y - yaw_model.global_position.y
	var v: float = affector.force
	var g: float = ProjectSettings.get_setting("physics/3d/default_gravity")
	var v2: float = pow(v, 2)
	var angle: float = atan((v2 + sqrt(pow(v, 4) - g * ((g * pow(x, 2)) + (2 * y * v2)))) / (g * x))
	yaw_model.look_at(Vector3(t_pos.x, yaw_model.global_position.y, t_pos.y))
	yaw_model.rotate(yaw_model.global_transform.basis.x.normalized(), angle)
