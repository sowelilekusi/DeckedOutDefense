extends ProjectileWeapon
class_name BombLauncherWeapon


func _ready() -> void:
	super._ready()
	var launch_range = stats.get_attribute("Range")
	force = sqrt((launch_range * ProjectSettings.get_setting("physics/3d/default_gravity")) / sin(2 * 45))
