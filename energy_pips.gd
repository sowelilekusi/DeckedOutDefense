class_name EnergyPips
extends Control

@export var tex: TextureRect

var energy: int :
	get():
		return energy
	set(value):
		energy = value
		if energy == max_energy:
			tex.texture.region.position.x = 0.0
		elif energy > 0:
			tex.texture.region.position.x = 21.0 * floori(lerp(11, 1, float(energy) / max_energy))
		else:
			tex.texture.region.position.x = 21.0 * 12


var max_energy: int :
	get():
		return max_energy
	set(value):
		max_energy = value
		energy = max_energy
