class_name OverclockTower
extends Tower

func shoot() -> void:
	#affector.apply_effect(effect, target_finder.targets)
	for tower: TowerBase in get_tree().get_nodes_in_group("TowerBases"):
		if tower.tower and tower.tower.stats != stats:
			if tower.global_position.distance_to(global_position) <= target_range:
				tower.tower.small_speed_buff_timer += time_between_shots
	animator.play("shoot")
	audio_player.play()
	if is_multiplayer_authority():
		networked_shoot.rpc()
