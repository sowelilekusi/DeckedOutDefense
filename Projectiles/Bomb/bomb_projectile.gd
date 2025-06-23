class_name BombProjectile
extends ExplosiveProjectile

var max_bounces: int = 1
var bounces: int = 0


func _ready() -> void:
	apply_central_impulse(direction.normalized() * force)
	#print(direction.length())
	#print(force)
	if owner_id == 0:
		max_bounces = 0


func _on_body_entered(_body: Node) -> void:
	bounces += 1
	var collided_body: bool = get_colliding_bodies()[0].get_collision_layer_value(3)
	if bounces > max_bounces or collided_body:
		explode()
