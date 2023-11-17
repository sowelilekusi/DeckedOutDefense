extends StatusApplyingTower
class_name RangeAffectingTower


func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority():
		return
	var enemies_in_range = []
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if !is_instance_valid(enemy) or !enemy.alive or global_position.distance_to(enemy.global_position) > target_range:
			continue
		enemies_in_range.append(enemy)
	if time_since_firing >= time_between_shots:
		time_since_firing -= time_between_shots
		for enemy in enemies_in_range:
			fire(enemy)


func fire(target):
	if is_instance_valid(target) and target.alive:
		target.damage(damage)
		target.status_manager.add_effect(build_status_object())
		if Data.preferences.display_tower_damage_indicators:
			spawn_damage_indicator(target.sprite.global_position)
	if is_multiplayer_authority():
		networked_fire.rpc(get_tree().root.get_path_to(target))


@rpc("reliable")
func networked_fire(target_node_path):
	var target = get_tree().root.get_node(target_node_path)
	fire(target)
