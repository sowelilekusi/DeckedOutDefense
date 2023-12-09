extends Node3D
class_name ViewMovement

@export var player : Hero
@export_category("Bobbing")
@export var head_bob_camera : Camera3D
@export var head_bob_focus_raycast : RayCast3D
@export var enable_head_bob := true
@export var head_bob_max_effect_velocity := 6.5
@export var head_bob_amplitude := 0.06
@export var head_bob_frequency := 0.02
@export var target_stabilisation := false
@export_category("Tilting")
@export var enable_tilt := true
@export var tilt_max_effect_velocity := 6.5
@export var tilt_amount_x := 0.03
@export var tilt_amount_y := 0.00

var lemniscate_sample_point = 0.0


func _process(delta: float) -> void:
	var player_velocity = player.velocity.length()
	if enable_head_bob:
		check_motion(delta, player_velocity)
		if target_stabilisation:
			head_bob_camera.look_at(focus_target())
	if enable_tilt:
		tilt_cam(delta, player_velocity)


func check_motion(delta, vel) -> void:
	var amp = vel / head_bob_max_effect_velocity
	if !player.is_on_floor():
		reset_position(delta)
		return
	lemniscate_sample_point += (delta * 1000.0) * head_bob_frequency * amp
	play_motion(sample_lemniscate(lemniscate_sample_point, vel), delta)


func reset_position(delta) -> void:
	if head_bob_camera.position != Vector3.ZERO:
		head_bob_camera.position = lerp(head_bob_camera.position, Vector3.ZERO, 7.0 * delta)


func sample_lemniscate(t: float, v: float) -> Vector2:
	var pos := Vector2.ZERO
	var amp = head_bob_amplitude * (v / head_bob_max_effect_velocity)
	pos.y += sin(t) * amp
	pos.x += cos(t / 2.0) * amp * 2.0
	return pos


func play_motion(motion: Vector2, delta) -> void:
	var motion3d = Vector3(motion.x, motion.y, 0.0)
	head_bob_camera.position = lerp(head_bob_camera.position, motion3d, 7.0 * delta)


func focus_target() -> Vector3:
	if head_bob_focus_raycast.is_colliding():
		return head_bob_focus_raycast.get_collision_point()
	else:
		return head_bob_focus_raycast.global_position + -head_bob_focus_raycast.global_transform.basis.z * 15.0


func tilt_cam(delta, vel):
	var dot = player.velocity.normalized().dot(-global_transform.basis.z)
	dot = -abs(dot) + 1
	dot *= vel / tilt_max_effect_velocity
	var input_vector = Input.get_vector("Move Left", "Move Right", "Move Forward", "Move Backward")
	head_bob_camera.rotation.z = lerp(head_bob_camera.rotation.z, tilt_amount_x * dot * -input_vector.x, 8.0 * delta)
	head_bob_camera.rotation.x = lerp(head_bob_camera.rotation.x, tilt_amount_y * (1.0 - dot) * input_vector.y, 8.0 * delta)
