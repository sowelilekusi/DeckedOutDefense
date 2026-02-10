class_name DriftlingDrippler
extends Node

enum DriftlingDrippleState {
	BLOATING = 0,
	FLOATING = 1,
	CHOAKING = 2,
	CROAKING = 3
}

@export var driftling: EnemyController
@export var animator: AnimationTree
@export var model: Node3D
@export var bloat_hitbox: Hitbox
@export var croak_hitbox: Hitbox

var time_to_bloat: float = 1.5
var time_to_float: float = 3.0
var time_to_choak: float = 0.8
var time_to_croak: float = 0.4


func _ready() -> void:
	time_to_bloat += NoiseRandom.randf_in_range(name.to_int(), 0.0, 0.5)
	time_to_float += NoiseRandom.randf_in_range(name.to_int(), 0.0, 2.0)
	time_to_choak += NoiseRandom.randf_in_range(name.to_int(), 0.0, 0.4)
	time_to_croak += NoiseRandom.randf_in_range(name.to_int(), 0.0, 0.2)
	next_state(DriftlingDrippleState.BLOATING)


func set_dripple(amount: float) -> void:
	animator.set("parameters/Blend2/blend_amount", amount)


func next_state(state: DriftlingDrippleState) -> void:
	var tween: Tween = create_tween()
	
	match state:
		DriftlingDrippleState.BLOATING:
			tween.tween_method(set_dripple, 1.0, 0.0, time_to_bloat)
			tween.tween_property(model, "position", Vector3.UP * 3.0, time_to_bloat)
			tween.tween_callback(next_state.bind(DriftlingDrippleState.FLOATING))
		DriftlingDrippleState.FLOATING:
			bloat_hitbox.disabled = false
			tween.tween_interval(time_to_float)
			tween.tween_callback(next_state.bind(DriftlingDrippleState.CHOAKING))
		DriftlingDrippleState.CHOAKING:
			bloat_hitbox.disabled = true
			tween.tween_method(set_dripple, 0.0, 1.0, time_to_croak)
			tween.tween_property(model, "position", Vector3.DOWN * 3.0, time_to_croak)
			tween.tween_callback(next_state.bind(DriftlingDrippleState.CROAKING))
		DriftlingDrippleState.CROAKING:
			tween.tween_interval(time_to_float)
			tween.tween_callback(next_state.bind(DriftlingDrippleState.BLOATING))
