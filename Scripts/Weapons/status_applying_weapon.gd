extends HitscanWeapon
class_name StatusApplyingWeapon

@export var status_stats : StatusStats


func hit(target, target_hitbox : Hitbox):
	super.hit(target, target_hitbox)
	target.status_manager.add_effect(build_status_object())


func build_status_object() -> StatusEffect:
	var status = StatusEffect.new()
	status.stats = status_stats
	return status
