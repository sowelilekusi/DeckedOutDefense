class_name FlamethrowerTower extends ShapecastTower


func build_status_object() -> StatusEffect:
	var status: StatusDoT = StatusDoT.new()
	status.stats = status_stats
	return status
