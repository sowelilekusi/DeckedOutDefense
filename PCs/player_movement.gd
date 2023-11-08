extends Node
class_name PlayerMovement

@export var player : CharacterBody3D
@export var head : Camera3D
@export var movement_speed := 3.5
@export var sprint_boost := 0.1
@export var acceleration := 0.8
@export var friction_percentage := 0.15
var zoom_factor := 1.0
var input_vector : Vector2
var can_sprint := true
var sprint_zoom_factor := 0.08
var sprinting := false
var head_angle := 0.0
var look_sens : float :
	set(value):
		return
	get:
		return Data.preferences.mouse_sens / 40000.0


func _physics_process(delta: float) -> void:
	var accel = acceleration
	if sprinting:
		accel = acceleration + sprint_boost
	var result_vector = input_vector * accel
	var down_velocity = player.velocity.y
	player.velocity = player.velocity.limit_length(player.velocity.length() * (1.0 - friction_percentage))
	player.velocity += ((player.transform.basis.z * result_vector.y) + (player.transform.basis.x * result_vector.x))
	player.velocity.y = down_velocity
	player.velocity += Vector3.DOWN * 9.81 * delta
	player.move_and_slide()
	sync_position.rpc(player.position)
	sync_rotation.rpc(player.rotation)


func _process(delta: float) -> void:
	can_sprint = true
	input_vector = Input.get_vector("Move Left", "Move Right", "Move Forward", "Move Backward")
	if input_vector.y >= 0:
		can_sprint = false
	if Data.preferences.toggle_sprint:
		if Input.is_action_just_pressed("Sprint"):
			sprinting = !sprinting
	else:
		sprinting = Input.is_action_pressed("Sprint")
	if !can_sprint:
		sprinting = false
	if Input.is_action_just_pressed("Jump") and player.is_on_floor():
		player.velocity.y += 4.5


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		player.rotation.y -= event.relative.x * (look_sens / zoom_factor) * (-1 if Data.preferences.invert_lookX else 1)
		head_angle -= event.relative.y * (look_sens / zoom_factor) * (-1 if Data.preferences.invert_lookY else 1)
		head_angle = clamp(head_angle, -1.5, 1.5)
		head.rotation.x = head_angle


@rpc
func sync_position(vec):
	player.position = vec


@rpc
func sync_rotation(rot):
	player.rotation = rot
