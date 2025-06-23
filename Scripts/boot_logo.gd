class_name BootLogo
extends TextureRect

signal animation_finished()

var time: float = 0.0
var x: int = 0
var y: int = 0
var signalled: bool = false
@export var color_rect: ColorRect


func _process(delta: float) -> void:
	time += delta
	if time >= (1.0 / 24.0):
		time -= (1.0 / 24.0)
		x += 1
		if x >= 10:
			x = 0
			y += 1
		if y == 4 and x == 4:
			var tween: Tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(color_rect, "offset_top", 155.0, 1.5)
		if y == 8 and x == 4:
			y = 7
			x = 5
			if !signalled:
				signalled = true
				animation_finished.emit()
		texture.region = Rect2(256.0 * x, 256.0 * y, 256.0, 256.0)
