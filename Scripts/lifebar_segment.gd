class_name LivesBarSegment
extends Control

var lives_left: int = 6

func take_life(value: int) -> void:
	for x: int in value:
		lives_left -= 1
		if lives_left == 5:
			$AnimationPlayer.play("lose1")
		if lives_left == 4:
			$AnimationPlayer2.play("lose2")
		if lives_left == 3:
			$AnimationPlayer3.play("lose3")
		if lives_left == 2:
			$AnimationPlayer4.play("lose4")
		if lives_left == 1:
			$AnimationPlayer5.play("lose5")
		if lives_left == 0:
			$AnimationPlayer6.play("lose6")
