class_name ItemCard
extends StaticBody3D

@export var card: Card


func pick_up() -> Card:
	$CollisionShape3D.call_deferred("set_disabled", true)
	$model/CSGSphere3D.set_visible(false)
	$AudioStreamPlayer3D.play()
	networked_pick_up.rpc()
	return card


@rpc
func networked_pick_up() -> void:
	$CollisionShape3D.call_deferred("set_disabled", true)
	$model/CSGSphere3D.set_visible(false)
	$AudioStreamPlayer3D.play()


func _on_audio_stream_player_3d_finished() -> void:
	queue_free()
