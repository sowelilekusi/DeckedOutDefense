extends Tower
class_name StickyTower

@export var status_stats : StatusStats


func shoot():
	var status = StatusSticky.new()
	status.stats = status_stats
	targeted_enemy.status_manager.add_effect(status)
