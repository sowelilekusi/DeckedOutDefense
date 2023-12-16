extends Projectile
class_name ExplosiveProjectile

@export var explosion_range := 3.0

var exploded := false
var sound_done := false
var particles_done := false


func _process(delta: float) -> void:
	super._process(delta)
	if !exploded and time_alive >= lifetime:
		explode()


func _on_body_entered(_body: Node) -> void:
	explode()


func explode():
	if is_multiplayer_authority() and !exploded:
		freeze = true
		exploded = true
		$CollisionShape3D.call_deferred("set_disabled", true)
		for enemy in get_tree().get_nodes_in_group("Enemies"):
			if global_position.distance_to(enemy.global_position) <= explosion_range:
				hit(enemy)
				networked_hit.rpc(get_tree().root.get_path_to(enemy))
		networked_kill.rpc()
		$Sprite3D.set_visible(false)
		$GPUParticles3D.emitting = true
		$AudioStreamPlayer.play()


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


@rpc("reliable")
func networked_kill():
	$Sprite3D.set_visible(false)
	$GPUParticles3D.emitting = true
	$AudioStreamPlayer.play()


func _on_audio_stream_player_finished() -> void:
	sound_done = true
	if sound_done and particles_done:
		queue_free()


func _on_gpu_particles_3d_finished() -> void:
	particles_done = true
	if sound_done and particles_done:
		queue_free()
