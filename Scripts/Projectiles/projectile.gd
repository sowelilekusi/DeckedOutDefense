extends RigidBody3D
class_name Projectile

@export var collision_shape : CollisionShape3D

var damage_particle_scene = preload("res://Scenes/damage_particle.tscn")
var owner_id = 0 #should be left unchanged by towers, 1 for host, peer_id on peers
var direction := Vector3.FORWARD
var force := 2.0
var damage := 0.0
var lifetime := 10.0
var time_alive := 0.0


func _ready() -> void:
	apply_central_impulse(direction * force)


func _process(delta: float) -> void:
	time_alive += delta


func spawn_damage_indicator(pos):
	if damage > 0:
		var marker = damage_particle_scene.instantiate()
		get_tree().root.add_child(marker)
		marker.set_number(damage)
		marker.position = pos


func _on_body_entered(_body: Node) -> void:
	pass # Replace with function body.


@rpc("reliable")
func networked_kill():
	queue_free()