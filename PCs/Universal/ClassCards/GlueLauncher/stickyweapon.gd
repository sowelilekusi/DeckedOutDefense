extends Weapon
class_name StickyWeapon

@export var status_stats : StatusStats

func shoot():
	if other_cooldown <= 0 and stats != null:
		other_cooldown = cooldown
		$AnimationPlayer.play("shoot")
		if $RayCast3D.is_colliding():
			var target = $RayCast3D.get_collider()
			if target != null:
				var target_hitbox = target.shape_owner_get_owner($RayCast3D.get_collider_shape())
				if target_hitbox is Hitbox:
					var status = StatusSticky.new()
					status.stats = status_stats
					target.status_manager.add_effect(status)
