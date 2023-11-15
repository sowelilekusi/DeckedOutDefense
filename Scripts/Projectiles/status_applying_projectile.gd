extends ExplosiveProjectile
class_name StatusApplyingProjectile

@export var status_stats : StatusStats


func hit(target):
	super.hit(target)
	target.status_manager.add_effect(build_status_object())


func build_status_object() -> StatusEffect:
	var status = StatusEffect.new()
	status.stats = status_stats
	return status
