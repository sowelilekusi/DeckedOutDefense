class_name GlueLauncherTower extends StatusApplyingTower


func build_status_object() -> StatusEffect:
	var status: StatusSlow = StatusSlow.new()
	status.stats = status_stats
	return status
