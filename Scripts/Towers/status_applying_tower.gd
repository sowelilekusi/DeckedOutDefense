class_name StatusApplyingTower extends HitscanTower

@export var status_stats: StatusStats


func shoot() -> void:
	super.shoot()
	if targeted_enemy and is_instance_valid(targeted_enemy) and targeted_enemy.alive:
		targeted_enemy.damage(damage)
		targeted_enemy.status_manager.add_effect(build_status_object())


func build_status_object() -> StatusEffect:
	var status: StatusEffect = StatusEffect.new()
	status.stats = status_stats
	return status


@rpc("reliable")
func networked_shoot() -> void:
	super.networked_shoot()
