extends ShapecastTower
class_name FlamethrowerTower


func build_status_object() -> StatusEffect:
	var status = StatusDoT.new()
	status.stats = status_stats
	return status
