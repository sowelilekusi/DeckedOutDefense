extends RigidBody3D
class_name Rocket

@export var damage := 10.0
@export var explosion_range := 6.0
var target : Node3D
var acceleration := 15.0
var direction
var lifetime := 15.0
var time_alive := 0.0


func _process(delta: float) -> void:
	time_alive += delta
	if time_alive >= lifetime:
		explode()


func _physics_process(_delta: float) -> void:
	if is_instance_valid(target):
		direction = global_position.direction_to(target.global_position)
	apply_central_force(direction * acceleration)


func _on_body_entered(_body: Node) -> void:
	explode()


func explode():
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if global_position.distance_to(enemy.global_position) <= explosion_range:
			enemy.damage(damage)
	queue_free()
