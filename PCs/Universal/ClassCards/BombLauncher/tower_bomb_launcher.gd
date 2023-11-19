extends ProjectileTower
class_name BombLauncherTower


func _ready() -> void:
	super._ready()
	force = sqrt((target_range * ProjectSettings.get_setting("physics/3d/default_gravity")) / sin(2 * 45))


func aim():
	super.aim()
	var pos = Vector2(global_position.x, global_position.z)
	var t_pos = Vector2(targeted_enemy.global_position.x, targeted_enemy.global_position.z)
	var x = pos.distance_to(t_pos)
	var y = targeted_enemy.global_position.y - yaw_model.global_position.y
	var v = force
	var g = ProjectSettings.get_setting("physics/3d/default_gravity")
	var v2 = pow(v, 2)
	var angle = atan((v2 + sqrt(pow(v, 4) - g * ((g * pow(x, 2)) + (2 * y * v2)))) / (g * x))
	yaw_model.look_at(Vector3(t_pos.x, yaw_model.global_position.y, t_pos.y))
	yaw_model.rotate(yaw_model.global_transform.basis.x.normalized(), angle)
