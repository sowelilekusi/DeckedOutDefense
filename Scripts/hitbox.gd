class_name Hitbox extends CollisionShape3D

signal took_damage(amount: float)


func damage(amount: float) -> void:
	took_damage.emit(amount)
