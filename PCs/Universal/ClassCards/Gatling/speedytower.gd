extends Tower
class_name SpeedyTower

var third_cooldown := 0.0

var time_since_firing_started := 0.0
var time_to_reach_max_speed := 3.0
var max_speed_multiplier := 2.0
var destination_multiplier := 0.0

func _ready() -> void:
	cooldown = 1.0 / stats.fire_rate
	destination_multiplier = 1.0 / max_speed_multiplier


func _process(delta: float) -> void:
	other_cooldown -= delta
	if !targeted_enemy:
		acquire_target()
	else:
		if model.global_position.distance_to(targeted_enemy.global_position) > stats.fire_range:
			targeted_enemy = null
			time_since_firing_started = 0.0
			third_cooldown = cooldown
		if targeted_enemy:
			time_since_firing_started += delta
			var progress = clamp(time_since_firing_started / time_to_reach_max_speed, 0, 1.0)
			third_cooldown = cooldown * (1.0 - (destination_multiplier * progress))
			aim()
			if other_cooldown <= 0:
				shoot()
				other_cooldown = third_cooldown
