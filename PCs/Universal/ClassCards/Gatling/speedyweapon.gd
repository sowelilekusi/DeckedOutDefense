extends Weapon
class_name SpeedyWeapon

var third_cooldown := 0.0

var time_since_firing_started := 0.0
var time_to_reach_max_speed := 3.0
var max_speed_multiplier := 2.0
var destination_multiplier := 0.0


func _ready() -> void:
	cooldown = 1.0 / stats.fire_rate
	destination_multiplier = 1.0 / max_speed_multiplier
	$RayCast3D.target_position = Vector3(0, 0, -stats.fire_range)


func set_raycast_origin(node):
	$RayCast3D.global_position = node.global_position


func _process(delta: float) -> void:
	if stats != null:
		other_cooldown -= delta
	if trigger_held:
		time_since_firing_started += delta
		var progress = clamp(time_since_firing_started / time_to_reach_max_speed, 0, 1.0)
		third_cooldown = cooldown * (1.0 - (destination_multiplier * progress))


func _physics_process(_delta: float) -> void:
	if trigger_held:
		shoot()


func hold_trigger():
	trigger_held = true


func release_trigger():
	trigger_held = false
	time_since_firing_started = 0.0
	third_cooldown = cooldown


func shoot():
	if other_cooldown <= 0 and stats != null:
		other_cooldown = third_cooldown
		$AnimationPlayer.play("shoot")
		if $RayCast3D.is_colliding():
			var target = $RayCast3D.get_collider()
			if target != null:
				var target_hitbox = target.shape_owner_get_owner($RayCast3D.get_collider_shape())
				if target_hitbox is Hitbox:
					target_hitbox.damage(stats.damage)

@rpc
func networked_shoot():
	$AnimationPlayer.play("shoot")
	
