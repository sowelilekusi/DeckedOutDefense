class_name WeaponMovement
extends Node3D

@export var player: CharacterBody3D

@export_category("Strafe Tilting")
@export var enable_strafe_tilt: bool = false
@export var tilt_max_effect_speed: float = 4.317
@export var tilt_amount_x: float = 0.75
@export var tilt_amount_y: float = 0.0

@export var weapon_rotation_amount: float = 1
@export var enable_mouse_sway: bool = true
var mouse_input: Vector2
var invert_weapon_sway: bool = true


func _process(delta: float) -> void:
	var tilt: Vector3 = Vector3.ZERO
	var sway: Vector3 = Vector3.ZERO
	if enable_strafe_tilt:
		tilt = get_strafe_tilt(player.velocity)
	if enable_mouse_sway:
		sway = weapon_sway(delta)
	rotation = lerp(rotation, tilt + sway, 10 * delta)


func get_strafe_tilt(player_velocity: Vector3) -> Vector3:
	var side_dot: float = player_velocity.normalized().dot(-global_transform.basis.z)
	var front_dot: float = player_velocity.normalized().dot(-global_transform.basis.x)
	var tilt_speed_factor: float = player_velocity.length() / tilt_max_effect_speed
	var tilt_vector: Vector3 = Vector3.ZERO
	tilt_vector.z = deg_to_rad(tilt_amount_x * front_dot * tilt_speed_factor)
	tilt_vector.x = deg_to_rad(tilt_amount_y * -side_dot * tilt_speed_factor)
	return tilt_vector


func weapon_sway(delta: float) -> Vector3:
	var vector: Vector3 = Vector3.ZERO
	vector.x = mouse_input.y * weapon_rotation_amount * (-1 if invert_weapon_sway else 1)
	vector.y = mouse_input.x * weapon_rotation_amount * (-1 if invert_weapon_sway else 1)
	return vector
