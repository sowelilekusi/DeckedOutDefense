class_name Corpse
extends RigidBody3D


func set_sprite(tex: Texture) -> void:
	$Sprite3D.texture = tex


func _ready() -> void:
	var tween: Tween = create_tween()
	tween.tween_interval(20.0)
	tween.tween_property($Sprite3D, "modulate", Color(1.0, 1.0, 1.0, 0.0), 4.0)
	tween.tween_callback(queue_free)


func _on_body_entered(_body: Node) -> void:
	freeze = true
