class_name EnemyController extends CharacterBody3D

signal reached_goal(enemy: Enemy, penalty: int)
signal died(enemy: Enemy)

@export var stats: Enemy
@export var status_manager: StatusEffector
@export var movement_controller: EnemyMovement
@export var health: Health
@export var d_n: Node3D
#@export var sprite: Sprite3D
@export var corpse_scene: PackedScene

var movement_speed: float
var movement_speed_penalty: float = 1.0
var alive: bool = true


func _ready() -> void:
	health.max_health = stats.health
	health.current_health = stats.health
	$SubViewport/HealthBar.setup(stats.health)
	#sprite.texture = stats.sprite.duplicate()
	movement_speed = stats.movement_speed
	status_manager.enemy = self


func apply_effect(effect: Effect) -> void:
	health.take_damage(effect.damage)
	for status: StatusEffect in effect.status_effects:
		status_manager.add_effect(status)


func goal_entered() -> void:
	if alive:
		alive = false
		reached_goal.emit(stats, stats.penalty)
		queue_free()


func die() -> void:
	if alive:
		alive = false
		died.emit(stats)
		var corpse: RigidBody3D = corpse_scene.instantiate()
		corpse.set_sprite(stats.death_sprite)
		corpse.position = global_position
		Game.level.corpses.add_child(corpse)
		queue_free()
