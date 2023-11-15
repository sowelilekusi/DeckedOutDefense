extends StatusApplyingTower
class_name GlueLauncherTower


func build_status_object() -> StatusEffect:
	var status = StatusSlow.new()
	status.stats = status_stats
	return status
