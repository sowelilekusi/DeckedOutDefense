class_name ViewMovement extends Node3D

@export var player: Hero

@export_category("Bobbing")
@export var camera: Camera3D
@export var focus_raycast: RayCast3D
@export var enable_head_bob: bool = true
@export var head_bob_max_effect_speed: float = 4.317
@export var head_bob_amplitude: float = 0.08
@export var head_bob_frequency: float = 8.0
@export var target_stabilisation: bool = false

@export_category("Strafe Tilting")
@export var enable_strafe_tilt: bool = false
@export var tilt_max_effect_speed: float = 4.317
@export var tilt_amount_x: float = 0.75
@export var tilt_amount_y: float = 0.0

var sample_point: float = 0.0
var speed_factor: float = 0.0

var trauma: float = 0.0
var trauma_recovery_speed: float = 0.7
var camera_shake: float = 0.0
var noise_sample: float = 0.0
var shake_speed: float = 50.0
var max_shake_angle: float = 45.0
var pitch_noise: FastNoiseLite = FastNoiseLite.new()
var yaw_noise: FastNoiseLite = FastNoiseLite.new()
var roll_noise: FastNoiseLite = FastNoiseLite.new()
var constant_trauma: float = 0.0


func _ready() -> void:
	pitch_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	yaw_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	roll_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	pitch_noise.frequency = 0.03
	yaw_noise.frequency = 0.03
	roll_noise.frequency = 0.01
	var noise_seed: int = randi()
	pitch_noise.seed = noise_seed
	yaw_noise.seed = noise_seed + 1
	roll_noise.seed = noise_seed + 2


func _physics_process(delta: float) -> void:
	if enable_head_bob and player.is_on_floor():
		#TODO: maybe make the speed slower/faster on slopes?
		var player_speed: float = Vector2(player.velocity.x, player.velocity.z).length()
		speed_factor = lerp(speed_factor, player_speed / head_bob_max_effect_speed, 20.0 * delta)
	else:
		speed_factor = lerp(speed_factor, 0.0, 20.0 * delta)


func _process(delta: float) -> void:
	#trauma = max(0.0, trauma - ((1.0 / trauma_recovery_speed) * delta))
	#camera_shake = pow(max(trauma, constant_trauma), 2.0)
	#noise_sample += shake_speed * delta
	#$Camera3D/ProgressBar.value = max(trauma, constant_trauma) * 100.0
	#$Camera3D/ProgressBar2.value = camera_shake * 100.0
	#if Input.is_action_just_pressed("damage"):
		#add_trauma()
	#if Input.is_action_just_pressed("big_damage"):
		#add_trauma(1.0)
	#if Input.is_action_just_pressed("increase_trauma"):
		#constant_trauma = min(1.0, constant_trauma + 0.1)
	#if Input.is_action_just_pressed("decrease_trauma"):
		#constant_trauma = max(0.0, constant_trauma - 0.1)
	sample_point += delta * head_bob_frequency * speed_factor
	var camera_translation: Vector3 = Vector3.ZERO
	var camera_tilt: Vector3 = Vector3.ZERO
	camera_translation = minecraft_translation(head_bob_amplitude * speed_factor)
	camera_tilt += minecraft_tilt(head_bob_amplitude * speed_factor)
	if target_stabilisation:
		camera.look_at(focus_target())
	if enable_strafe_tilt:
		camera_tilt += get_strafe_tilt(player.velocity)
	#var shake_vector: Vector3 = Vector3.ZERO
	#shake_vector.x = deg_to_rad(pitch_noise.get_noise_1d(noise_sample) * camera_shake * max_shake_angle)
	#shake_vector.y = deg_to_rad(yaw_noise.get_noise_1d(noise_sample) * camera_shake * max_shake_angle)
	#shake_vector.z = deg_to_rad(roll_noise.get_noise_1d(noise_sample) * camera_shake * max_shake_angle)
	#camera_tilt += shake_vector
	camera.rotation = camera_tilt
	translate_camera(camera_translation)


func hfov_to_vfov(hfov_degrees: float) -> void:
	return rad_to_deg(2.0 * atan(tan(deg_to_rad(hfov_degrees) / 2.0) * 9.0 / 16.0))


func minecraft_translation(amplitude: float) -> Vector3:
	return sample_u_shape(sample_point, amplitude, 0.7)


func minecraft_tilt(amplitude: float) -> Vector3:
	var pitch_angle: float = deg_to_rad(5)
	var roll_angle: float = deg_to_rad(2)
	var x: float = -abs(sin(sample_point + (PI / 2))) * pitch_angle * amplitude
	var z: float = sin(sample_point) * roll_angle * amplitude
	return Vector3(x, 0.0, z)


func sample_sine(sample: float, amplitude: float) -> Vector3:
	return Vector3(0.0, sin(sample) * amplitude, 0.0)


func sample_lemniscate(sample: float, amplitude: float, ratio: float = 1.0) -> Vector3:
	var y: float = sin(sample) * amplitude
	var x: float = (cos(sample / 2.0) * amplitude * 2.0) * ratio
	return Vector3(x, y, 0.0)


func sample_u_shape(sample: float, amplitude: float, ratio: float = 1.0) -> Vector3:
	var y: float = ((abs(sin(sample + (PI / 2.0)))) * amplitude) - (amplitude / 2.0)
	var x: float = sin(sample) * amplitude * ratio
	return Vector3(x, y, 0.0)


func translate_camera(offset: Vector3) -> void:
	var target_position: Vector3 = Vector3.ZERO
	target_position += global_transform.basis.x * offset.x
	target_position += Vector3.UP * offset.y
	target_position += global_transform.basis.z * offset.z
	camera.global_position = global_position + target_position


func focus_target() -> Vector3:
	if focus_raycast.is_colliding():
		return focus_raycast.get_collision_point()
	else:
		return focus_raycast.global_position + -focus_raycast.global_transform.basis.z * 30.0


#func tilt_camera(tilt: Vector3, speed: float) -> void:
	##camera.rotation.x = lerp(camera.rotation.x, tilt.x, speed)
	##camera.rotation.y = lerp(camera.rotation.y, tilt.y, speed)
	##camera.rotation.z = lerp(camera.rotation.z, tilt.z, speed)
	#camera.rotation.x = tilt.x
	#camera.rotation.y = tilt.y
	#camera.rotation.z = tilt.z


func get_strafe_tilt(player_velocity: Vector3) -> Vector3:
	var side_dot: float = player_velocity.normalized().dot(-global_transform.basis.z)
	var front_dot: float = player_velocity.normalized().dot(-global_transform.basis.x)
	var tilt_speed_factor: float = player_velocity.length() / tilt_max_effect_speed
	var tilt_vector: Vector3 = Vector3.ZERO
	tilt_vector.z = deg_to_rad(tilt_amount_x * front_dot * tilt_speed_factor)
	tilt_vector.x = deg_to_rad(tilt_amount_y * -side_dot * tilt_speed_factor)
	return tilt_vector


func add_trauma(amount: float = 0.3) -> void:
	trauma = min(1.0, trauma + amount)
