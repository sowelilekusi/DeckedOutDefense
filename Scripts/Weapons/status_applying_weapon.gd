class_name StatusApplyingWeapon
extends HitscanWeapon

@export var status_stats: StatusStats


func hit(hitbox: Hitbox, hit_pos: Vector3) -> void:
	super.hit(hitbox, hit_pos)
	hitbox.add_effect(build_status_object())


func build_status_object() -> StatusEffect:
	var status: StatusEffect = StatusEffect.new()
	status.stats = status_stats
	return status
