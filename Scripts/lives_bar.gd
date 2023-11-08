extends TextureRect

@export var segments : Array[LivesBarSegment]
var lives := 120.0


func take_life():
	var segment_to_animate = ceil(lives / 6.0) - 1
	lives -= 1
	segments[segment_to_animate].take_life(1)
