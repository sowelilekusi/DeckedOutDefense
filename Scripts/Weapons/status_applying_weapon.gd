class_name StatusApplyingWeapon
extends HitscanWeapon

@export var status_stats: StatusStats


func hit(target: CharacterBody3D, target_hitbox: Hitbox) -> void:
	super.hit(target, target_hitbox)
	target.status_manager.add_effect(build_status_object())


func build_status_object() -> StatusEffect:
	var status: StatusEffect = StatusEffect.new()
	status.stats = status_stats
	return status
