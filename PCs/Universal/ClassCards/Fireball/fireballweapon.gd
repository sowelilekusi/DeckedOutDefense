extends Weapon
class_name FireballWeapon

@export var fireball_scene : PackedScene
@export var status_stats : StatusStats


func shoot():
	if other_cooldown <= 0 and stats != null:
		other_cooldown = cooldown
		$AnimationPlayer.play("shoot")
		var fireball = fireball_scene.instantiate() as Fireball
		fireball.position = $RayCast3D.global_position
		fireball.status_stats = status_stats
		get_tree().root.add_child(fireball)
		fireball.direction = -global_transform.basis.z
