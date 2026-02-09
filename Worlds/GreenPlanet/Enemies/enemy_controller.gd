class_name EnemyController extends CharacterBody3D

signal reached_goal(enemy: Enemy, penalty: int)
signal died(enemy: Enemy)
signal health_changed(health: int)

@export var stats: Enemy
@export var status_manager: StatusEffector
@export var movement_controller: EnemyMovement
@export var max_health: int = 10
@export var d_n: Node3D
#@export var sprite: Sprite3D
@export var corpse_scene: PackedScene
@export var health_bar: HealthBar

var damage_particle_scene: PackedScene = preload("res://UI/DamageParticle/damage_particle.tscn")
var current_health: int
var corpse_root: Node
var movement_speed: float
var movement_speed_penalty: float = 1.0
var alive: bool = true


func _ready() -> void:
	max_health = stats.health
	current_health = stats.health
	health_changed.connect(health_bar.on_health_changed)
	health_bar.setup(stats.health)
	movement_speed = stats.movement_speed
	status_manager.enemy = self


func spawn_damage_indicator(damage: int, pos: Vector3, damage_type: Data.DamageIndicationType) -> void:
	var color: Color = Color.WHITE
	if damage_type == Data.DamageIndicationType.PLAYER:
		if !Data.preferences.display_self_damage_indicators:
			return
		else:
			color = Color.FIREBRICK
	if damage_type == Data.DamageIndicationType.TOWER:
		if !Data.preferences.display_tower_damage_indicators:
			return
		else:
			color = Color.WHITE_SMOKE
	if damage_type == Data.DamageIndicationType.OTHER_PLAYER:
		if !Data.preferences.display_party_damage_indicators:
			return
		else:
			color = Color.AQUAMARINE
	if damage_type == Data.DamageIndicationType.STATUS:
		if !Data.preferences.display_status_effect_damage_indicators:
			return
		else:
			color = Color.INDIAN_RED
	var marker: DamageParticle = damage_particle_scene.instantiate()
	get_tree().root.add_child(marker)
	marker.set_number(damage)
	marker.set_color(color)
	marker.position = pos


func take_damage(damage: int, damage_type: Data.DamageIndicationType = Data.DamageIndicationType.TOWER, damage_point: Vector3 = global_position) -> void:
	current_health -= damage
	health_changed.emit(current_health)
	if damage > 0:
		spawn_damage_indicator(damage, damage_point, damage_type)
	if current_health <= 0:
		die()


func heal_damage(healing: int) -> void:
	current_health += healing
	if current_health > max_health:
		current_health = max_health
	health_changed.emit(current_health)


func apply_effect(effect: Effect) -> void:
	take_damage(effect.damage)
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
		var corpse: RigidBody3D = corpse_scene.instantiate()
		corpse.set_sprite(stats.death_sprite)
		corpse.position = global_position
		corpse_root.add_child(corpse)
		died.emit(stats)
		queue_free()
