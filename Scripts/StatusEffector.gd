extends Node3D
class_name StatusEffector

@export var hbox : HBoxContainer

var icon_scene = preload("res://Scenes/status_icon.tscn")
var effects : Array[StatusEffect]
var icons : Array[TextureRect]


func add_effect(new_effect : StatusEffect):
	var icon_present = false
	for effect in effects:
		if effect.stats == new_effect.stats:
			icon_present = true
	new_effect.expired.connect(remove_effect)
	effects.append(new_effect)
	if !icon_present:
		var icon = icon_scene.instantiate()
		icon.texture = new_effect.stats.icon
		icons.append(icon)
		hbox.add_child(icon)


func remove_effect(expiring_effect : StatusEffect):
	effects.erase(expiring_effect)
	var has_remaining_stack = false
	for effect in effects:
		if effect.stats == expiring_effect.stats:
			has_remaining_stack = true
	if !has_remaining_stack:
		for icon in icons:
			if icon.texture == expiring_effect.stats.icon:
				icons.erase(icon)
				icon.queue_free()
				break
