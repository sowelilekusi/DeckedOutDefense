extends CharacterBody3D
class_name EnemyController

signal reached_goal(enemy, penalty)
signal died(enemy)

@export var stats: Enemy
@export var status_manager: StatusEffector
@export var movement_controller: EnemyMovement
@export var health: Health
@export var sprite: Sprite3D
@export var corpse_scene: PackedScene

var movement_speed: float
var movement_speed_penalty := 1.0
var alive = true


func _ready() -> void:
	health.max_health = stats.health
	health.current_health = stats.health
	$SubViewport/HealthBar.setup(stats.health)
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
		var corpse = corpse_scene.instantiate()
		corpse.set_sprite(stats.death_sprite)
		corpse.position = global_position
		Game.level.corpses.add_child(corpse)
		queue_free()
