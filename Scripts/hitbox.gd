extends CollisionShape3D
class_name Hitbox

signal took_damage(amount)


func damage(amount):
	networked_damage.rpc(amount)


@rpc("any_peer","call_local")
func networked_damage(amount):
	took_damage.emit(amount)
