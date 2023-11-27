extends Node3D
class_name ViewMovement

@export var player : Hero
@export_category("Bobbing")
@export var head_bob_camera : Camera3D
@export var head_bob_focus_raycast : RayCast3D
@export var enable_head_bob := true
@export var target_stabilisation := false
@export_category("Tilting")
@export var enable_tilt := true

var head_bob_amplitude := 0.002
var head_bob_frequency := 0.015
var tilt_amount := 0.04
var head_bob_start_position : Vector3


func _ready() -> void:
	head_bob_start_position = head_bob_camera.position


func _process(delta: float) -> void:
	if enable_head_bob:
		check_motion(delta)
		if target_stabilisation:
			head_bob_camera.look_at(focus_target())
	if enable_tilt:
		tilt_cam(delta)


func check_motion(delta) -> void:
	var speed = player.velocity.length_squared()
	if speed < 2.0:
		reset_position(delta)
		return
	if !player.is_on_floor():
		reset_position(delta)
		return
	play_motion(foot_step_motion())


func reset_position(delta) -> void:
	if head_bob_camera.position != head_bob_start_position:
		head_bob_camera.position = lerp(head_bob_camera.position, head_bob_start_position, 10.0 * delta)


func foot_step_motion() -> Vector3:
	var pos := Vector3.ZERO
	pos.y += cos(Time.get_ticks_msec() * head_bob_frequency) * head_bob_amplitude
	pos.x += cos(Time.get_ticks_msec() * head_bob_frequency / 2.0) * head_bob_amplitude * 2.0
	return pos


func play_motion(motion: Vector3) -> void:
	head_bob_camera.position += motion


func focus_target() -> Vector3:
	if head_bob_focus_raycast.is_colliding():
		return head_bob_focus_raycast.get_collision_point()
	else:
		return head_bob_focus_raycast.global_position + -head_bob_focus_raycast.global_transform.basis.z * 15.0


func tilt_cam(delta):
	if player.velocity.length() < 1.0:
		return
	var dot = player.velocity.normalized().dot(-global_transform.basis.z)
	dot = -abs(dot) + 1
	var input_vector = Input.get_vector("Move Left", "Move Right", "Move Forward", "Move Backward")
	head_bob_camera.rotation.z = lerp(head_bob_camera.rotation.z, tilt_amount * dot * -input_vector.x, 8.0 * delta)
	#head_bob_camera.rotation.x = lerp(head_bob_camera.rotation.x, tilt_amount * dot * input_vector.y, 8.0 * delta)
