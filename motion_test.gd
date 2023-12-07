extends Sprite2D

#var head_bob_amplitude := 100.0
@export var head_bob_amplitude := 50.0
#var head_bob_amplitude := 1.0
@export var head_bob_frequency := 0.015
#var head_bob_frequency := 0.030


func _process(delta: float) -> void:
	check_motion(delta)


func check_motion(delta) -> void:
	if Input.is_action_pressed("Primary Fire"):
		play_motion(foot_step_motion(), delta)
	else:
		reset_position(delta)


func reset_position(delta) -> void:
	if position != Vector2.ZERO:
		position = lerp(position, Vector2.ZERO, 10.0 * delta)


func foot_step_motion() -> Vector2:
	var pos := Vector2.ZERO
	var t = Time.get_ticks_msec() * head_bob_frequency
	pos.y += sin(t) * head_bob_amplitude
	pos.x += cos(t / 2.0) * head_bob_amplitude * 2.0
	return pos


func play_motion(motion: Vector2, delta) -> void:
	position = lerp(position, motion, 10.0 * delta)
	#position = motion
	#position += motion
