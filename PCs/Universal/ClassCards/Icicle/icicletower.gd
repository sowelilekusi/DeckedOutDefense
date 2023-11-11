extends Tower
class_name IcicleTower

@export var icicle_scene : PackedScene
@export var status_stats : StatusStats


func shoot():
	var icicle = icicle_scene.instantiate() as Icicle
	icicle.position = model.global_position
	icicle.status_stats = status_stats
	get_tree().root.add_child(icicle)
	icicle.direction = -model.global_transform.basis.z
