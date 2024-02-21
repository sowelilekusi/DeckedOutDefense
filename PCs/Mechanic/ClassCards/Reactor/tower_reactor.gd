class_name ReactorTower extends RangeAffectingTower

@export var particles: GPUParticles3D


func _ready() -> void:
	super._ready()
	particles.process_material.emission_ring_radius = target_range


func build_status_object() -> StatusEffect:
	var status: StatusDoT = StatusDoT.new()
	status.stats = status_stats
	return status
