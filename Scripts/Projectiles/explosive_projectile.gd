extends Projectile
class_name ExplosiveProjectile

@export var explosion_range := 3.0


func _process(delta: float) -> void:
	super._process(delta)
	if time_alive >= lifetime:
		explode()


func _on_body_entered(_body: Node) -> void:
	explode()


func explode():
	if is_multiplayer_authority():
		for enemy in get_tree().get_nodes_in_group("Enemies"):
			if global_position.distance_to(enemy.global_position) <= explosion_range:
				hit(enemy)
				networked_hit.rpc(get_tree().root.get_path_to(enemy))
		networked_kill.rpc()
		queue_free()


func hit(target):
	target.damage(damage)
	if owner_id == 0:
		if Data.preferences.display_tower_damage_indicators:
			spawn_damage_indicator(target.sprite.global_position)
	if owner_id == multiplayer.get_unique_id():
		if Data.preferences.display_self_damage_indicators:
			spawn_damage_indicator(target.sprite.global_position)
	if owner_id != 0 and owner_id != multiplayer.get_unique_id():
		if Data.preferences.display_party_damage_indicators:
			spawn_damage_indicator(target.sprite.global_position)


@rpc("reliable")
func networked_hit(target_node_path):
	var target = get_tree().root.get_node(target_node_path)
	hit(target)
