class_name Hitbox
extends CollisionShape3D

@export var critical_zone: bool = false

signal took_damage(amount: int)


func damage(amount: int) -> void:
	took_damage.emit(amount * 1.5 if critical_zone else amount)
