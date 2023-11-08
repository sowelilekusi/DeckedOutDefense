extends Tower
class_name BombTower

@export var bomb_scene: PackedScene
var firing_velocity

func _ready() -> void:
	super._ready()
	firing_velocity = sqrt((stats.fire_range * ProjectSettings.get_setting("physics/3d/default_gravity")) / sin(2 * 45))


func shoot():
	var bomb = bomb_scene.instantiate() as Bomb
	bomb.position = model.global_position
	bomb.damage = stats.damage
	get_tree().root.add_child(bomb)
	bomb.apply_impulse(-model.global_transform.basis.z * firing_velocity)


func aim():
	var pos = Vector2(global_position.x, global_position.z)
	var t_pos = Vector2(targeted_enemy.global_position.x, targeted_enemy.global_position.z)
	var x = pos.distance_to(t_pos)
	var y = targeted_enemy.global_position.y - global_position.y
	var v = firing_velocity
	var g = ProjectSettings.get_setting("physics/3d/default_gravity")
	var v2 = pow(v, 2)
	var angle = atan((v2 + sqrt(pow(v, 4) - g * ((g * pow(x, 2)) + (2 * y * v2)))) / (g * x))
	model.look_at(Vector3(t_pos.x, model.global_position.y, t_pos.y))
	model.rotate(model.global_transform.basis.x.normalized(), angle)
