extends Tower
class_name StickyTower

@export var status_stats : StatusStats


func shoot():
	var status = StatusSticky.new()
	status.stats = status_stats
	status.affected = targeted_enemy
	status.affected.status_manager.add_effect(status)
	targeted_enemy.add_child(status)
