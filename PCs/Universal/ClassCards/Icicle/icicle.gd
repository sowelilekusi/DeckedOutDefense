extends RigidBody3D
class_name Icicle

@export var explosion_range := 6.0
var acceleration := 15.0
var direction
var status_stats : StatusStats
var lifetime := 15.0
var time_alive := 0.0


func _process(delta: float) -> void:
	time_alive += delta
	if time_alive >= lifetime:
		explode()


func _physics_process(_delta: float) -> void:
	apply_central_force(direction * acceleration)


func _on_body_entered(_body: Node) -> void:
	explode()


func explode():
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if global_position.distance_to(enemy.global_position) <= explosion_range:
			var status = StatusCold.new()
			status.stats = status_stats
			enemy.status_manager.add_effect(status)
	queue_free()
