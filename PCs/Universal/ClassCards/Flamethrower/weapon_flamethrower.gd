extends ShapecastWeapon
class_name FlamethrowerWeapon

func build_status_object() -> StatusEffect:
	var status = StatusDoT.new()
	status.stats = status_stats
	return status
