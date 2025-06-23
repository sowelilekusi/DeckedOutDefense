class_name LivesBar
extends TextureRect

@export var segments: Array[LivesBarSegment]
var lives: float = 120.0


func take_life() -> void:
	var segment_to_animate: int = ceil(lives / 6.0) - 1
	lives -= 1
	segments[segment_to_animate].take_life(1)
