extends Node
class_name StatusEffect

signal expired(effect : StatusEffect)

var stats : StatusStats

var affected : 
	set(value):
		affected = value
		on_attached()
var cooldown := 0.0
var other_cooldown := 0.0
var time_existed := 0.0


func on_attached():
	pass


func on_removed():
	expired.emit(self)


func proc():
	pass


func _ready():
	other_cooldown = 1.0 / stats.proc_frequency


func _process(delta: float) -> void:
	time_existed += delta
	if time_existed >= stats.duration:
		on_removed()
		queue_free()
		return
	if stats.proc_frequency > 0.0:
		cooldown += delta
		if cooldown >= other_cooldown:
			cooldown -= other_cooldown
			proc()
		
