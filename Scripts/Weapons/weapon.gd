class_name Weapon extends Node3D

signal energy_changed(energy: int)

@export var stats: CardText
@export var animator: AnimationPlayer
@export var audio_player: AudioStreamPlayer3D
@export var recharge_timer: Timer

var damage_particle_scene: PackedScene = preload("res://Scenes/damage_particle.tscn")
var hero: Hero
var trigger_held: bool = false
var second_trigger_held: bool = false
var time_since_firing: float = 0.0
var time_between_shots: float = 0.0
var damage: float = 0.0
var max_energy: float = 100.0
var current_energy: float = 100.0
var energy_cost: float = 1.0
var recharging: bool = false
var recharge_speed: float = 0.0
var recharge_acceleration: float = 2.0
var recharge_max_speed: float = 25.0


func _ready() -> void:
	time_between_shots = stats.get_attribute("Fire Delay")
	damage = stats.get_attribute("Damage")
	energy_cost = stats.get_attribute("Energy")


func set_hero(value: Hero) -> void:
	hero = value


func _process(delta: float) -> void:
	if recharging:
		recharge_speed += recharge_acceleration * delta
		if recharge_speed > recharge_max_speed:
			recharge_speed = recharge_max_speed
		current_energy += recharge_speed * delta
		if current_energy >= max_energy:
			current_energy = max_energy
	energy_changed.emit(current_energy)
	if time_since_firing < time_between_shots:
		time_since_firing += delta


func _physics_process(_delta: float) -> void:
	if trigger_held and current_energy >= energy_cost and time_since_firing >= time_between_shots:
		time_since_firing -= time_between_shots
		current_energy -= energy_cost
		energy_changed.emit(current_energy)
		shoot()
		networked_shoot.rpc()


func hold_trigger() -> void:
	trigger_held = true


func release_trigger() -> void:
	if trigger_held:
		recharge_timer.start()
	trigger_held = false


func hold_second_trigger() -> void:
	second_trigger_held = true


func release_second_trigger() -> void:
	second_trigger_held = false


func spawn_damage_indicator(pos: Vector3) -> void:
	if damage > 0:
		var marker: Node3D = damage_particle_scene.instantiate()
		get_tree().root.add_child(marker)
		marker.set_number(damage)
		marker.position = pos


func shoot() -> void:
	animator.play("shoot")
	audio_player.play()
	recharging = false
	recharge_speed = 0.0
	recharge_timer.stop()


@rpc
func networked_shoot() -> void:
	animator.play("shoot")
	audio_player.play()


func _on_timer_timeout() -> void:
	recharging = true
