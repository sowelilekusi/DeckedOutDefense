extends Tower
class_name BlowdartTower

@export var status_stats : StatusStats


func shoot():
	var status = StatusPoison.new()
	status.stats = status_stats
	targeted_enemy.status_manager.add_effect(status)
