extends RigidBody3D
class_name Bomb

@export var max_bounces := 1
@export var damage := 10.0
@export var explosion_range := 3.0
var bounces := 0

func _on_body_entered(_body: Node) -> void:
	bounces += 1
	var collided_body = get_colliding_bodies()[0].get_collision_layer_value(3)
	if bounces > max_bounces or collided_body:
		explode()


func explode():
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if global_position.distance_to(enemy.global_position) <= explosion_range:
			enemy.damage(damage)
	queue_free()
