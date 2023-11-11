extends Tower
class_name FireballTower

@export var fireball_scene : PackedScene
@export var status_stats : StatusStats


func shoot():
	var fireball = fireball_scene.instantiate() as Fireball
	fireball.position = model.global_position
	fireball.status_stats = status_stats
	get_tree().root.add_child(fireball)
	fireball.direction = -model.global_transform.basis.z
