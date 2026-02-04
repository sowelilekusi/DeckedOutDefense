class_name FloatingElement extends MarginContainer

var dest: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var acceleration: float = 3.0
var max_speed: float = 30.0


func _process(delta: float) -> void:
	#var direction: Vector2 = (dest - position).normalized()
	#velocity += direction * acceleration
	#velocity = velocity.limit_length(max_speed)
	#position += velocity * delta
	position = position.lerp(dest, 15.0 * delta)


func set_text(text: String) -> void:
	$Label.text = text
