extends RefCounted
class_name StatusEffect

var stats : StatusStats

var time_since_proc := 0.0
var time_existed := 0.0


func on_attached(affected, existing_effects):
	pass


func on_removed(affected, existing_effects):
	pass


func proc(affected, stacks, existing_effects):
	pass
