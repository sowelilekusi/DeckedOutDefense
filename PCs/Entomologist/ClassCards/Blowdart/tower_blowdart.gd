class_name BlowdartTower extends StatusApplyingTower


func build_status_object() -> StatusEffect:
	var status: StatusDoT = StatusDoT.new()
	status.stats = status_stats
	return status
