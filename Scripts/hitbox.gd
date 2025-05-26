class_name Hitbox extends CollisionShape3D

signal took_damage(amount: int)


func damage(amount: int) -> void:
	took_damage.emit(amount)
