class_name HitscanTower extends Tower


func shoot() -> void:
	super.shoot()
	target_finder.get_target().damage(damage)
	if Data.preferences.display_tower_damage_indicators:
		spawn_damage_indicator(target_finder.get_target().sprite.global_position)


@rpc("reliable")
func networked_shoot() -> void:
	super.networked_shoot()
