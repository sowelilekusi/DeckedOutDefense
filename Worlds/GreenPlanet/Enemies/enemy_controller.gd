extends PathFollow3D
class_name EnemyController

signal reached_goal(penalty)
signal died

var alive = true

@export var stats : Enemy
@export var status_manager : StatusEffector
var movement_speed

func _ready() -> void:
	$Dog/Health.max_health = stats.health
	$Dog/Health.current_health = stats.health
	$Dog/SubViewport/ProgressBar.max_value = stats.health
	$Dog/SubViewport/ProgressBar.value = stats.health
	$Dog/DirectionSprite.texture = stats.sprite.duplicate()
	movement_speed = stats.movement_speed


func damage(amount):
	$Dog/Hitbox.damage(amount)


func _physics_process(delta: float) -> void:
	progress += movement_speed * delta
	if progress_ratio >= 1:
		reached_goal.emit(stats.penalty)
		queue_free()


func die():
	died.emit()
	queue_free()


func _on_health_health_depleted() -> void:
	if alive:
		alive = false
		die()


func _on_health_health_changed(health) -> void:
	$Dog/SubViewport/ProgressBar.value = health
	var percent = float($Dog/Health.current_health) / float($Dog/Health.max_health)
	$Dog/SubViewport/ProgressBar.tint_progress = Color(1 - percent, percent, 0.0)
	$Dog/SubViewport/ProgressBar.set_visible(true)
