class_name RefrigeratorTower extends RangeAffectingTower

@export var particles: GPUParticles3D


func _ready() -> void:
	super._ready()
	particles.process_material.emission_ring_radius = target_range


func build_status_object() -> StatusEffect:
	var status: StatusSlow = StatusSlow.new()
	status.stats = status_stats
	return status
