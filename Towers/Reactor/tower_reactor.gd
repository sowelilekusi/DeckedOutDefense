class_name ReactorTower
extends Tower

@export var particles: GPUParticles3D


func _ready() -> void:
	super._ready()
	particles.process_material.emission_ring_radius = target_range
