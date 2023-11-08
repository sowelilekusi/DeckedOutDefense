extends Weapon
class_name ScopedWeapon

var scope_mask : Texture


func hold_second_trigger():
	super.hold_second_trigger()
	$CanvasLayer.set_visible(true)
	hero.zoom_factor = 3.0


func release_second_trigger():
	super.release_second_trigger()
	$CanvasLayer.set_visible(false)
