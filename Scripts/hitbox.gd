class_name Hitbox
extends CollisionShape3D

@export var critical_zone: bool = false

signal took_damage(amount: int, damage_type: Data.DamageIndicationType, pos: Vector3)
signal recieved_effect(effect: StatusEffect)


func damage(amount: int, damage_type: Data.DamageIndicationType = Data.DamageIndicationType.PLAYER, pos: Vector3 = global_position) -> void:
	took_damage.emit(roundi(amount * 1.5) if critical_zone else amount, damage_type, pos)


func apply_effect(effect: StatusEffect) -> void:
	recieved_effect.emit(effect)
