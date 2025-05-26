class_name PlayerMovement extends Node

@export var player: CharacterBody3D
@export var head: Node3D

#Most of the default values are based primarily on minecraft, but the
#movement code does not replicate how movement in minecraft works

@export_category("Movement")
@export_subgroup("Basic")
@export var hard_speed_limit: float = 4.317
@export var toggle_sprint: bool = false
@export var limit_sprint_to_forward: bool = true
@export var sprint_boost: float = 1.3
@export var acceleration: float = 0.9
@export var friction_percentage: float = 0.15
@export var air_drag: float = 0.03
@export_range(0.0, 90.0) var max_look_down_angle: float = 90.0
@export_range(0.0, 90.0) var max_look_up_angle: float = 90.0
@export_range(0.0, 1.0) var air_control: float = 0.2
@export var climb_speed: float = 3.0

@export_subgroup("Jump")
@export var enable_jumping: bool = false
@export var min_height: float = 1.25
@export var max_height: float = 1.25
@export var time_to_peak: float = 0.3
@export var time_to_floor: float = 0.3

@export_subgroup("Crouch")
@export var enable_crouching: bool = false
@export var standing_collider: CollisionShape3D
@export var crouching_collider: CollisionShape3D
@export var crouch_shapecast: ShapeCast3D

@export_category("Look")
@export_range(1.0, 100.0) var sensitivity: float = 28.0
@export var invert_y: bool = false
@export var invert_x: bool = false

@onready var jump_velocity: float = (2 * max_height) / time_to_peak
@onready var jump_gravity: float = (-2 * max_height) / pow(time_to_peak, 2)
@onready var fall_gravity: float = (-2 * max_height) / pow(time_to_floor, 2)
@onready var time_to_min_peak: float = (clampf(min_height, 0.0, max_height) / max_height) * time_to_peak
@onready var min_jump_gravity: float = (-2 * clampf(min_height, 0.0, max_height)) / pow(time_to_min_peak, 2)

var ragdoll: bool = false
var paused: bool = false
var zoom_factor: float = 1.0
var input_vector: Vector2 = Vector2.ZERO
var look_vector: Vector2 = Vector2.ZERO
var joystick_deadzone: float = 0.12
var can_sprint: bool = true
var sprint_zoom_factor: float = 0.08
var sprinting: bool = false
var jump_held: bool = false
var is_in_climb_zone: bool = false
var hold_climb: bool = false
var ragdoll_grace_period_length: float = 0.5
var ragdoll_grace_period_elapsed: float = 0.0

var crouching: bool = false
var prev_crouch_height: float = 0.0
var new_crouch_height: float = 0.0
var default_camera_height: float = 0.0
var change_crouch: bool = false

var head_angle: float = 0.0
var look_sens: float :
	set(_value):
		return
	get:
		return sensitivity / 40000.0


func _ready() -> void:
	default_camera_height = head.position.y


func get_gravity() -> float:
	if jump_held:
		return jump_gravity if player.velocity.y > 0.0 else fall_gravity
	return min_jump_gravity if player.velocity.y > 0.0 else fall_gravity


func apply_ragdoll(vector: Vector3) -> void:
	ragdoll = true
	player.velocity = vector
	print(vector)


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	if ragdoll:
		player.velocity += Vector3.DOWN * 9.81 * delta
		ragdoll_grace_period_elapsed += delta
		if player.is_on_floor() and ragdoll_grace_period_elapsed >= ragdoll_grace_period_length:
			ragdoll_grace_period_elapsed = 0.0
			ragdoll = false
		player.move_and_slide()
		return
	var result_vector: Vector2 = input_vector * acceleration
	if !player.is_on_floor():
		result_vector *= air_control
	var velocity: Vector2 = Vector2(player.velocity.x, player.velocity.z)
	var down_velocity: float = player.velocity.y
	var movement: Vector3 = ((player.transform.basis.z * result_vector.y) + (player.transform.basis.x * result_vector.x))
	if player.is_on_floor():
		velocity = velocity.limit_length(velocity.length() * (1.0 - friction_percentage))
	velocity = velocity.limit_length(velocity.length() * (1.0 - air_drag))
	velocity += Vector2(movement.x, movement.z)
	velocity = velocity.limit_length(hard_speed_limit * sprint_boost if sprinting else hard_speed_limit)
	if !is_in_climb_zone:
		if !player.is_on_floor():
			player.velocity = Vector3(velocity.x, down_velocity + (get_gravity() * delta), velocity.y)
		else:
			player.velocity = Vector3(velocity.x, down_velocity, velocity.y)
	else:
		if jump_held:
			player.velocity = Vector3(velocity.x, climb_speed, velocity.y)
		elif hold_climb:
			player.velocity = Vector3(velocity.x, 0.0, velocity.y)
		else:
			player.velocity = Vector3(velocity.x, -climb_speed, velocity.y)
	if change_crouch:
		if !crouching:
			standing_collider.disabled = true
			crouching_collider.disabled = false
			crouching = true
		else:
			standing_collider.disabled = false
			crouching_collider.disabled = true
			crouching = false
		change_crouch = false
	player.move_and_slide()


func _process(_delta: float) -> void:
	if !is_multiplayer_authority():
		return
	if paused:
		input_vector = Vector2.ZERO
		return
	can_sprint = true
	input_vector = Input.get_vector("Move Left", "Move Right", "Move Forward", "Move Backward")
	if limit_sprint_to_forward and input_vector.y >= 0:
		can_sprint = false
	if toggle_sprint:
		if Input.is_action_just_pressed("Sprint"):
			sprinting = !sprinting
	else:
		sprinting = Input.is_action_pressed("Sprint")
	if !can_sprint:
		sprinting = false
	if enable_jumping:
		if Input.is_action_just_pressed("Jump") and player.is_on_floor() and !is_in_climb_zone:
			player.velocity.y = jump_velocity
			jump_held = true
	if Input.is_action_just_pressed("Jump") and is_in_climb_zone:
		jump_held = true
	if Input.is_action_just_released("Jump"):
		jump_held = false
	if enable_crouching:
		if Input.is_action_just_pressed("Crouch"):
			if !crouching:
				prev_crouch_height = 0.0
				new_crouch_height = default_camera_height
				change_crouch = true
			elif !crouch_shapecast.is_colliding():
				tween_head_height(default_camera_height + 0.2)
				change_crouch = true
	if crouching:
		crouch()
	if Input.is_action_just_pressed("Crouch") and is_in_climb_zone:
		hold_climb = true
	if Input.is_action_just_released("Crouch") and is_in_climb_zone:
		hold_climb = false
	look_vector.x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	look_vector.y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	if look_vector.length_squared() <= joystick_deadzone:
		look_vector = Vector2(0.0, 0.0)
	player.rotation.y -= look_vector.x * 0.02
	head_angle -= look_vector.y * 0.02
	head_angle = clamp(head_angle, deg_to_rad(-max_look_down_angle), deg_to_rad(max_look_up_angle))
	head.rotation.x = head_angle


func enable_climbing() -> void:
	is_in_climb_zone = true


func disable_climbing() -> void:
	is_in_climb_zone = false
	hold_climb = false


func crouch() -> void:
	var lowest_crouch_point: float = default_camera_height
	for collider: Dictionary in crouch_shapecast.collision_result:
		var point: Vector3 = collider["point"]
		if crouch_shapecast.global_position.distance_to(point) + 0.6 < lowest_crouch_point:
			lowest_crouch_point = crouch_shapecast.global_position.distance_to(point) + 0.6
	if !crouch_shapecast.is_colliding():
		lowest_crouch_point = default_camera_height
	if abs(lowest_crouch_point - new_crouch_height) > 0.05:
		new_crouch_height = lowest_crouch_point
	if abs(new_crouch_height - prev_crouch_height) > 0.05:
		tween_head_height(new_crouch_height)
		prev_crouch_height = new_crouch_height


func tween_head_height(height: float) -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(head, "position", Vector3(0.0, height - 0.2, 0.0), 0.1)


func _unhandled_input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		player.rotation.y -= event.relative.x * (look_sens / zoom_factor) * (-1 if invert_x else 1)
		head_angle -= event.relative.y * (look_sens / zoom_factor) * (-1 if invert_y else 1)
		head_angle = clamp(head_angle, deg_to_rad(-max_look_down_angle), deg_to_rad(max_look_up_angle))
		head.rotation.x = head_angle
	elif event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_RIGHT_X:
			look_vector.x = event.axis_value
		elif event.axis == JOY_AXIS_RIGHT_Y:
			look_vector.y = event.axis_value
