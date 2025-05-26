class_name GlueLauncherWeapon extends StatusApplyingWeapon


func build_status_object() -> StatusEffect:
	var status: StatusSlow = StatusSlow.new()
	status.stats = status_stats
	return status
