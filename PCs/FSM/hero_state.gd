class_name HeroState
extends Node

@warning_ignore("unused_signal")
signal state_changed(new_state: HeroState)

@export var hero: Hero


func enter_state() -> void:
	pass


func exit_state() -> void:
	pass


@warning_ignore("unused_parameter")
func process_state(delta: float) -> void:
	pass
