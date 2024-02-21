class_name HitscanTower extends Tower


func shoot() -> void:
	super.shoot()
	if targeted_enemy and is_instance_valid(targeted_enemy) and targeted_enemy.alive:
		targeted_enemy.damage(damage)
		if Data.preferences.display_tower_damage_indicators:
			spawn_damage_indicator(targeted_enemy.sprite.global_position)


@rpc("reliable")
func networked_shoot() -> void:
	super.networked_shoot()
