extends Tower
class_name RefridgeratorTower

@export var status_stats : StatusStats
@export var particlesystem : GPUParticles3D


func aim():
	pass


func shoot():
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if global_position.distance_to(enemy.global_position) <= stats.fire_range:
			var status = StatusCold.new()
			status.stats = status_stats
			enemy.status_manager.add_effect(status)
