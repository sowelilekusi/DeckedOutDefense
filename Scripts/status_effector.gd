class_name StatusEffector extends Node

@export var sprite_container: Container ## Container that effect icons should be instantiated under

var enemy: EnemyController ## Enemy Controller that this node should affect
var icon_scene: PackedScene = preload("res://Scenes/status_icon.tscn")
var immunities: Array[StatusEffect] = [] ## The set of status effects that this effector shouldn't apply
var effects: Dictionary[StatusEffect, int] = {}
var icons: Dictionary[StatusEffect, TextureRect] = {}


func _process(delta: float) -> void:
	for effect: StatusEffect in effects:
		if effects[effect] == 0:
			continue
		effect.time_since_proc += delta
		effect.time_existed += delta
		if effect.stats.duration > 0.0 and effect.time_existed >= effect.stats.duration:
			effect.time_existed -= effect.stats.duration
			effects[effect] -= 1
			effect.on_removed(enemy, effects)
		if effects[effect] == 0:
			icons[effect].visible = false
		if effect.time_since_proc >= effect.stats.proc_cd:
			effect.proc(enemy, effects[effect], effects)
			effect.time_since_proc -= effect.stats.proc_cd


func force_proc(effect_to_proc: StatusEffect) -> void:
	for effect: StatusEffect in effects:
		if effect.stats == effect_to_proc.stats:
			effect.proc(enemy, effects[effect], effects)


func add_effect(new_effect: StatusEffect) -> void:
	# Return early if this node immune to the new effect
	for effect: StatusEffect in immunities:
		if effect.stats == new_effect.stats:
			return
	
	var existing_effect: StatusEffect = null
	for effect: StatusEffect in effects:
		if effect.stats == new_effect.stats:
			existing_effect = effect
	if !existing_effect:
		existing_effect = new_effect.duplicate()
		effects[existing_effect] = 0
		var icon: TextureRect = icon_scene.instantiate()
		icon.texture = existing_effect.stats.icon
		icons[existing_effect] = icon
		sprite_container.add_child(icon)
	
	if existing_effect.stats.max_stacks == 0 or effects[existing_effect] < existing_effect.stats.max_stacks:
		existing_effect.on_attached(enemy, effects)
		icons[existing_effect].visible = true
		effects[existing_effect] += 1
	existing_effect.time_existed = 0.0
