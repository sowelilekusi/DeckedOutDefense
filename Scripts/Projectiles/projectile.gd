class_name Projectile extends RigidBody3D

@export var collision_shape: CollisionShape3D

var damage_particle_scene: PackedScene = preload("res://Scenes/damage_particle.tscn")
var owner_id: int = 0 #should be left unchanged by towers, 1 for host, peer_id on peers
var direction: Vector3= Vector3.FORWARD
var force: float = 2.0
var damage: float = 0.0
var lifetime: float = 10.0
var time_alive: float = 0.0
var effect: Effect


func _ready() -> void:
	apply_central_impulse(direction * force)


func _process(delta: float) -> void:
	time_alive += delta


func spawn_damage_indicator(pos: Vector3) -> void:
	if effect.damage > 0:
		var marker: Node3D = damage_particle_scene.instantiate()
		get_tree().root.add_child(marker)
		marker.set_number(effect.damage)
		marker.position = pos


func _on_body_entered(_body: Node) -> void:
	pass # Replace with function body.


@rpc("reliable")
func networked_kill() -> void:
	queue_free()
