extends HitscanTower
class_name StatusApplyingTower

@export var status_stats : StatusStats


func shoot():
	super.shoot()
	if targeted_enemy and is_instance_valid(targeted_enemy) and targeted_enemy.alive:
		targeted_enemy.damage(damage)
		targeted_enemy.status_manager.add_effect(build_status_object())


func build_status_object() -> StatusEffect:
	var status = StatusEffect.new()
	status.stats = status_stats
	return status


@rpc("reliable")
func networked_shoot():
	super.networked_shoot()
