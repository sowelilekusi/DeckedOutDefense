extends CharacterBody3D
class_name AirEnemyController

signal reached_goal(enemy, penalty)
signal died(enemy)

var alive = true

@export var stats : Enemy
@export var status_manager : StatusEffector

var movement_speed
var movement_speed_penalty := 1.0
var progress := 0.0
var progress_ratio := 0.0
var destination : Node3D

func _ready() -> void:
	$Health.max_health = stats.health
	$Health.current_health = stats.health
	$SubViewport/ProgressBar.max_value = stats.health
	$SubViewport/ProgressBar.value = stats.health
	$Sprite3D3.texture = stats.sprite.duplicate()
	movement_speed = stats.movement_speed


func damage(amount):
	$Hitbox.damage(amount)


func _physics_process(delta: float) -> void:
	progress += (movement_speed * clampf(movement_speed_penalty, 0.0, 1.0)) * delta
	velocity = global_position.direction_to(destination.global_position) * (movement_speed * clampf(movement_speed_penalty, 0.0, 1.0))
	move_and_slide()
	if global_position.distance_to(destination.global_position) <= 1.0:
		reached_goal.emit(stats, stats.penalty)
		queue_free()


func die():
	died.emit(stats)
	queue_free()


func _on_health_health_depleted() -> void:
	if alive:
		alive = false
		die()


func _on_health_health_changed(health) -> void:
	$SubViewport/ProgressBar.value = health
	var percent = float($Health.current_health) / float($Health.max_health)
	$SubViewport/ProgressBar.tint_progress = Color(1 - percent, percent, 0.0)
	$SubViewport/ProgressBar.set_visible(true)
