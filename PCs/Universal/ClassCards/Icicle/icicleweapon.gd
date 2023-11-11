extends Weapon
class_name IcicleWeapon

@export var icicle_scene : PackedScene
@export var status_stats : StatusStats


func shoot():
	if other_cooldown <= 0 and stats != null:
		other_cooldown = cooldown
		$AnimationPlayer.play("shoot")
		var icicle = icicle_scene.instantiate() as Icicle
		icicle.position = $RayCast3D.global_position
		icicle.status_stats = status_stats
		get_tree().root.add_child(icicle)
		icicle.direction = -global_transform.basis.z
