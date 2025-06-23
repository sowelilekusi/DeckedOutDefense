class_name IcicleProjectile
extends StatusApplyingProjectile


func build_status_object() -> StatusEffect:
	var status: StatusSlow = StatusSlow.new()
	status.stats = status_stats
	return status
