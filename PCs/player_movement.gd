extends Node
class_name PlayerMovement

@export var player : CharacterBody3D
@export var head : Node3D

@export_category("Movement")
@export var movement_speed := 5.0
@export var sprint_boost := 1.3
@export var acceleration := 0.8
@export var friction_percentage := 0.1
@export var max_look_down_angle := 90.0
@export var max_look_up_angle := 90.0

@export_category("Jump")
@export var min_height := 0.8
@export var max_height := 1.3
@export var time_to_peak := 0.5
@export var time_to_floor := 0.35

@onready var jump_velocity : float = (2 * max_height) / time_to_peak
@onready var jump_gravity : float = (-2 * max_height) / pow(time_to_peak, 2)
@onready var fall_gravity : float = (-2 * max_height) / pow(time_to_floor, 2)
@onready var time_to_min_peak : float = (clampf(min_height, 0.0, max_height) / max_height) * time_to_peak
@onready var min_jump_gravity : float = (-2 * clampf(min_height, 0.0, max_height)) / pow(time_to_min_peak, 2)

var paused := false
var zoom_factor := 1.0
var input_vector : Vector2
var can_sprint := true
var sprint_zoom_factor := 0.08
var sprinting := false
var jump_held = false
var head_angle := 0.0
var look_sens : float :
	set(_value):
		return
	get:
		return Data.preferences.mouse_sens / 40000.0


func get_gravity() -> float:
	if jump_held:
		return jump_gravity if player.velocity.y > 0.0 else fall_gravity
	return min_jump_gravity if player.velocity.y > 0.0 else fall_gravity


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	var result_vector = input_vector * acceleration
	var velocity = Vector2(player.velocity.x, player.velocity.z)
	var down_velocity = player.velocity.y
	var movement = ((player.transform.basis.z * result_vector.y) + (player.transform.basis.x * result_vector.x))
	velocity = velocity.limit_length(velocity.length() * (1.0 - friction_percentage))
	velocity += Vector2(movement.x, movement.z)
	velocity = velocity.limit_length(movement_speed * sprint_boost if sprinting else movement_speed)
	player.velocity = Vector3(velocity.x, down_velocity + (get_gravity() * delta), velocity.y)
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
	if Data.preferences.toggle_sprint:
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


func _unhandled_input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		player.rotation.y -= event.relative.x * (look_sens / zoom_factor) * (-1 if Data.preferences.invert_lookX else 1)
		head_angle -= event.relative.y * (look_sens / zoom_factor) * (-1 if Data.preferences.invert_lookY else 1)
		head_angle = clamp(head_angle, deg_to_rad(-max_look_down_angle), deg_to_rad(max_look_up_angle))
		head.rotation.x = head_angle
