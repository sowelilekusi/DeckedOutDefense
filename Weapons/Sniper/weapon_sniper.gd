class_name SniperWeapon
extends HitscanWeapon

@export var scope_mask: CanvasLayer


func hold_second_trigger() -> void:
	super.hold_second_trigger()
	scope_mask.set_visible(true)
	hero.set_zoom_factor(3.0)


func release_second_trigger() -> void:
	super.release_second_trigger()
	scope_mask.set_visible(false)
