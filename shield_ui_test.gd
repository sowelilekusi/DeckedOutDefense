extends Control

@export var shield: ShieldUI
@export var lives_bar: LivesBar
@export var damage_label: Label

var damage: int = 1


func _ready() -> void:
	shield.fading_enabled = false


func increase_damage() -> void:
	damage += 1
	damage_label.text = str(damage)


func decrease_damage() -> void:
	damage -= 1
	if damage < 1:
		damage = 1
	damage_label.text = str(damage)


func hit() -> void:
	shield.take_damage(damage)
	for x: int in damage:
		lives_bar.take_life()
