class_name PlayerMovement extends Node

@export var player: CharacterBody3D
@export var head: Node3D

#Most of the default values are based primarily on minecraft, but the
#movement code does not replicate how movement in minecraft works

@export_category("Movement")
@export var movement_speed: float = 4.317
@export var toggle_sprint: bool = true
@export var sprint_boost: float = 1.3
@export var acceleration: float = 0.9
@export var friction_percentage: float = 0.1
@export_range(0.0, 90.0) var max_look_down_angle: float = 90.0
@export_range(0.0, 90.0) var max_look_up_angle: float = 90.0
@export var air_control: bool = true

@export_category("Jump")
@export var min_height: float = 1.25
@export var max_height: float = 1.25
@export var time_to_peak: float = 0.3
@export var time_to_floor: float = 0.3

@export_category("Look")
@export_range(1.0, 100.0) var sensitivity: float = 28.0
@export var invert_y: bool = false
@export var invert_x: bool = false

@onready var jump_velocity: float = (2 * max_height) / time_to_peak
@onready var jump_gravity: float = (-2 * max_height) / pow(time_to_peak, 2)
@onready var fall_gravity: float = (-2 * max_height) / pow(time_to_floor, 2)
@onready var time_to_min_peak: float = (clampf(min_height, 0.0, max_height) / max_height) * time_to_peak
@onready var min_jump_gravity: float = (-2 * clampf(min_height, 0.0, max_height)) / pow(time_to_min_peak, 2)

var paused: bool = false
var zoom_factor: float = 1.0
var input_vector: Vector2 = Vector2.ZERO
var look_vector: Vector2 = Vector2.ZERO
var joystick_deadzone: float = 0.12
var can_sprint: bool = true
var sprint_zoom_factor: float = 0.08
var sprinting: bool = false
var jump_held: bool = false
var head_angle: float = 0.0
var look_sens: float :
	set(_value):
		return
	get:
		return sensitivity / 40000.0


func get_gravity() -> float:
	if jump_held:
		return jump_gravity if player.velocity.y > 0.0 else fall_gravity
	return min_jump_gravity if player.velocity.y > 0.0 else fall_gravity


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	var result_vector: Vector2 = input_vector * acceleration
	var velocity: Vector2 = Vector2(player.velocity.x, player.velocity.z)
	var down_velocity: float = player.velocity.y
	var movement: Vector3 = ((player.transform.basis.z * result_vector.y) + (player.transform.basis.x * result_vector.x))
	velocity = velocity.limit_length(velocity.length() * (1.0 - friction_percentage))
	velocity += Vector2(movement.x, movement.z)
	velocity = velocity.limit_length(movement_speed * sprint_boost if sprinting else movement_speed)
	if air_control or player.is_on_floor():
		player.velocity = Vector3(velocity.x, down_velocity + (get_gravity() * delta), velocity.y)
	else:
		player.velocity = Vector3(player.velocity.x, down_velocity + (get_gravity() * delta), player.velocity.z)
	player.move_and_slide()


func _process(_delta: float) -> void:
	if !is_multiplayer_authority():
		return
	if paused:
		input_vector = Vector2.ZERO
		return
	can_sprint = true
	input_vector = Input.get_vector("Move Left", "Move Right", "Move Forward", "Move Backward")
	if input_vector.y >= 0:
		can_sprint = false
	if toggle_sprint:
		if Input.is_action_just_pressed("Sprint"):
			sprinting = !sprinting
	else:
		sprinting = Input.is_action_pressed("Sprint")
	if !can_sprint:
		sprinting = false
	if Input.is_action_just_pressed("Jump") and player.is_on_floor():
		player.velocity.y = jump_velocity
		jump_held = true
	if Input.is_action_just_released("Jump"):
		jump_held = false
	look_vector.x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	look_vector.y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	if look_vector.length_squared() <= joystick_deadzone:
		look_vector = Vector2(0.0, 0.0)
	player.rotation.y -= look_vector.x * 0.02
	head_angle -= look_vector.y * 0.02
	head_angle = clamp(head_angle, deg_to_rad(-max_look_down_angle), deg_to_rad(max_look_up_angle))
	head.rotation.x = head_angle


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
