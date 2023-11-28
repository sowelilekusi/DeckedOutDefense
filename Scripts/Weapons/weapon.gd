extends Node3D
class_name Weapon

signal energy_changed(energy)

@export var stats : CardText
@export var animator : AnimationPlayer
@export var recharge_timer : Timer

var damage_particle_scene = preload("res://Scenes/damage_particle.tscn")
var hero : Hero
var trigger_held := false
var second_trigger_held := false
var time_since_firing := 0.0
var time_between_shots := 0.0
var damage := 0.0
var max_energy := 100.0
var current_energy := 100.0
var energy_cost := 1.0
var recharging := false
var recharge_speed := 0.0
var recharge_acceleration = 2.0
var recharge_max_speed = 20.0


func _ready() -> void:
	time_between_shots = stats.get_attribute("Fire Delay")
	damage = stats.get_attribute("Damage")
	energy_cost = stats.get_attribute("Energy")


func set_hero(value):
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


func hold_trigger():
	trigger_held = true


func release_trigger():
	trigger_held = false
	recharge_timer.start()


func hold_second_trigger():
	second_trigger_held = true


func release_second_trigger():
	second_trigger_held = false


func spawn_damage_indicator(pos):
	if damage > 0:
		var marker = damage_particle_scene.instantiate()
		get_tree().root.add_child(marker)
		marker.set_number(damage)
		marker.position = pos


func shoot():
	animator.play("shoot")
	recharging = false
	recharge_timer.stop()


@rpc
func networked_shoot():
	animator.play("shoot")


func _on_timer_timeout() -> void:
	recharging = true
