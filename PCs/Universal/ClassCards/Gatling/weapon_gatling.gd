extends HitscanWeapon
class_name GatlingWeapon

var time_since_firing_started := 0.0
var time_to_reach_max_speed := 0.0
var max_speed_multiplier := 0.0
var current_time_between_shots := 0.0
var final_time_between_shots := 0.0


func _ready() -> void:
	super._ready()
	time_to_reach_max_speed = stats.get_attribute("Speed Time")
	max_speed_multiplier = stats.get_attribute("Speed Multiplier")
	final_time_between_shots = time_between_shots / max_speed_multiplier


func _process(delta: float) -> void:
	super._process(delta)
	if trigger_held:
		time_since_firing_started += delta
		var progress = clamp(time_since_firing_started / time_to_reach_max_speed, 0, 1.0)
		current_time_between_shots = lerpf(time_between_shots, final_time_between_shots, progress)
	if current_energy < energy_cost:
		time_since_firing_started = 0.0
		current_time_between_shots = time_between_shots


func _physics_process(_delta: float) -> void:
	if trigger_held and current_energy >= energy_cost and time_since_firing >= current_time_between_shots:
		time_since_firing -= current_time_between_shots
		current_energy -= energy_cost
		energy_changed.emit(current_energy)
		shoot()
		networked_shoot.rpc()


func release_trigger():
	super.release_trigger()
	time_since_firing_started = 0.0
	current_time_between_shots = time_between_shots
