extends Sprite2D

var look_vector: Vector2
var joystick_deadzone: float = 0.15


func _process(delta: float) -> void:
	look_vector.x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	look_vector.y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	if look_vector.length_squared() <= joystick_deadzone:
		look_vector = Vector2(0.0, 0.0)
	position.x = look_vector.x * 190
	position.y = look_vector.y * 190
