extends CollisionShape3D
class_name Hitbox

signal took_damage(amount)


func damage(amount):
	took_damage.emit(amount)
