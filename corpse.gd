extends RigidBody3D


func set_sprite(tex: Texture):
	$Sprite3D.texture = tex


func _ready() -> void:
	var tween = create_tween()
	tween.tween_interval(15.0)
	tween.tween_property($Sprite3D, "modulate", Color(1.0, 1.0, 1.0, 0.0), 4.0)
	tween.tween_callback(queue_free)


func _on_body_entered(body: Node) -> void:
	freeze = true
