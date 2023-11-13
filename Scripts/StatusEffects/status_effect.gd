extends RefCounted
class_name StatusEffect

var stats : StatusStats

var time_since_proc := 0.0
var time_existed := 0.0


func on_attached(_affected, _existing_effects):
	pass


func on_removed(_affected, _existing_effects):
	pass


func proc(_affected, _stacks, _existing_effects):
	pass
