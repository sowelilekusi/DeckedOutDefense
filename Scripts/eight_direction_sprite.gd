class_name EightDirectionSprite3D
extends Sprite3D


func _process(_delta: float) -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if !cam:
		return
	var tile_size: int = texture.region.size.x
	
	#stupid algorithm for dummy game developers
	var camera_look_dir_3D: Vector3 = cam.global_position.direction_to(global_position).normalized()
	var a: Vector2 = Vector2(global_transform.basis.z.x, global_transform.basis.z.z).normalized()
	var b: Vector2 = Vector2(camera_look_dir_3D.x, camera_look_dir_3D.z).normalized()
	var dot: float = a.x * b.x + a.y * b.y
	var det: float = a.x * b.y - a.y * b.x
	var final: float = rad_to_deg(atan2(det, dot)) + 180
	
	var t: Rect2 = texture.region
	if final > 337.5 or final < 22.5:
		t = Rect2(tile_size * 4, t.position.y, tile_size, tile_size)
	elif final > 22.5 and final < 67.5:
		t = Rect2(tile_size * 5, t.position.y, tile_size, tile_size)
	elif final > 67.5 and final < 112.5:
		t = Rect2(tile_size * 6, t.position.y, tile_size, tile_size)
	elif final > 112.5 and final < 157.5:
		t = Rect2(tile_size * 7, t.position.y, tile_size, tile_size)
	elif final > 157.5 and final < 202.5:
		t = Rect2(0, t.position.y, tile_size, tile_size)
	elif final > 202.5 and final < 247.5:
		t = Rect2(tile_size * 1, t.position.y, tile_size, tile_size)
	elif final > 247.5 and final < 292.5:
		t = Rect2(tile_size * 2, t.position.y, tile_size, tile_size)
	elif final > 292.5 and final < 337.5:
		t = Rect2(tile_size * 3, t.position.y, tile_size, tile_size)
	texture.region = t
