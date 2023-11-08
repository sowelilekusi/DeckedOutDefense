extends Weapon
class_name BombWeapon

@export var bomb_scene: PackedScene
var firing_velocity

func _ready() -> void:
	cooldown = 1.0 / stats.fire_rate
	firing_velocity = sqrt((stats.fire_range * ProjectSettings.get_setting("physics/3d/default_gravity")) / sin(2 * 45))
	$RayCast3D.target_position = Vector3(0, 0, -stats.fire_range)


func shoot():
	if other_cooldown <= 0 and stats != null:
		other_cooldown = cooldown
		$AnimationPlayer.play("shoot")
		var bomb = bomb_scene.instantiate() as Bomb
		bomb.position = $RayCast3D.global_position
		bomb.damage = stats.damage
		get_tree().root.add_child(bomb)
		bomb.apply_impulse(-global_transform.basis.z * firing_velocity)
