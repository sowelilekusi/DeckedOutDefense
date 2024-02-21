class_name GatlingTower extends HitscanTower

var time_since_firing_started: float = 0.0
var time_to_reach_max_speed: float = 0.0
var max_speed_multiplier: float = 0.0
var current_time_between_shots: float = 0.0
var final_time_between_shots: float = 0.0


func _ready() -> void:
	super._ready()
	time_to_reach_max_speed = stats.get_attribute("Speed Time")
	max_speed_multiplier = stats.get_attribute("Speed Multiplier")
	final_time_between_shots = time_between_shots / max_speed_multiplier


func _process(delta: float) -> void:
	if time_since_firing < current_time_between_shots:
		time_since_firing += delta


func _physics_process(delta: float) -> void:
	if !targeted_enemy:
		acquire_target()
	else:
		if !targeted_enemy.alive or global_position.distance_to(targeted_enemy.global_position) > target_range:
			targeted_enemy = null
			time_since_firing_started = 0.0
			current_time_between_shots = time_between_shots
		if targeted_enemy:
			aim()
			time_since_firing_started += delta
			var progress: float = clamp(time_since_firing_started / time_to_reach_max_speed, 0, 1.0)
			current_time_between_shots = lerpf(time_between_shots, final_time_between_shots, progress)
			if time_since_firing >= current_time_between_shots:
				time_since_firing -= current_time_between_shots
				shoot()
