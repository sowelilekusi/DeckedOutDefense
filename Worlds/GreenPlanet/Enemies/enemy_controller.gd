extends CharacterBody3D
class_name EnemyController

signal reached_goal(enemy, penalty)
signal died(enemy)

@export var stats : Enemy
@export var status_manager : StatusEffector
@export var movement_controller : EnemyMovement
@export var health : Health
@export var sprite : Sprite3D
@export var health_bar_gradient : Gradient

var movement_speed
var movement_speed_penalty := 1.0
var alive = true


func _ready() -> void:
	health.max_health = stats.health
	health.current_health = stats.health
	$SubViewport/ProgressBar.max_value = stats.health
	$SubViewport/ProgressBar.value = stats.health
	sprite.texture = stats.sprite.duplicate()
	movement_speed = stats.movement_speed


func damage(amount):
	$Hitbox.damage(amount)


func goal_entered():
	if alive:
		alive = false
		reached_goal.emit(stats, stats.penalty)
		queue_free()


func die():
	if alive:
		alive = false
		died.emit(stats)
		queue_free()


func _on_health_health_changed(value) -> void:
	$SubViewport/ProgressBar.value = value
	var percent = float(health.current_health) / float(health.max_health)
	$SubViewport/ProgressBar.tint_progress = health_bar_gradient.sample(percent)
	$SubViewport/ProgressBar.set_visible(true)
