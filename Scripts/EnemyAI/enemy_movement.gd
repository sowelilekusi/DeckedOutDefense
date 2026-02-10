class_name EnemyMovement
extends Node

@export var character: EnemyController

var distance_remaining: float = 0.0
var speed: float = 0.0


func _ready() -> void:
	var variance: float = NoiseRandom.randf_in_range(character.name.to_int(), -1.0, 1.0)
	var variance_max: float = 0.03 # Enemy speed can vary by 3% from their base speed
	speed = character.stats.movement_speed + (variance * variance_max)
