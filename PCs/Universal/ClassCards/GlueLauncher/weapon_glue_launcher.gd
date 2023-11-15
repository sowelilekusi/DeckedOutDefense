extends StatusApplyingWeapon


func build_status_object() -> StatusEffect:
	var status = StatusSlow.new()
	status.stats = status_stats
	return status
