extends StatusApplyingProjectile
class_name IcicleProjectile


func build_status_object() -> StatusEffect:
	var status = StatusSlow.new()
	status.stats = status_stats
	return status
