class_name SpriteBobber
extends Node

@export var character: EnemyController
@export var sprite: Node3D
@export var height: float = 0.1

var default_height: float = 0.0
var sample_point: float = 0.0


func _ready() -> void:
	default_height = sprite.position.y


func _process(delta: float) -> void:
	sample_point += delta * (character.stats.movement_speed * 2.0)
	var y_offset: float = sin(sample_point * 2.0) / 2.0 + 0.5
	var x_offset: float = cos(sample_point)
	sprite.position.y = default_height + (y_offset * height)
	sprite.position.x = x_offset * 0.05
