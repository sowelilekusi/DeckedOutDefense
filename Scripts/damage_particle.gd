extends Sprite3D

@onready var label: Label = $SubViewport/Label
var time_alive := 0.0
var movement_speed := 1.0
var movement_vector : Vector3

func _ready():
	var theta = deg_to_rad(40)
	var z = randf_range(cos(theta), 1)
	var phi = randf_range(0, 2 * PI)
	var vector = Vector3(sqrt(1 - pow(z, 2)) * cos(phi), z, sqrt(1 - pow(z, 2)) * sin(phi))
	movement_vector = vector.normalized()

func set_number(num):
	label.text = str(num)


func _process(delta: float) -> void:
	time_alive += delta
	position += movement_vector * movement_speed * delta
	if time_alive >= 1.0:
		queue_free()
