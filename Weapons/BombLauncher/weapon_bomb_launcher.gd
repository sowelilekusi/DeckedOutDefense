class_name BombLauncherWeapon
extends ProjectileWeapon


func _ready() -> void:
	super._ready()
	var launch_range: float = stats.get_attribute("Range")
	force = sqrt((launch_range * ProjectSettings.get_setting("physics/3d/default_gravity")) / sin(2.0 * 45.0))
