extends Node3D
class_name Weapon

@export var stats : CardText
@export var animator : AnimationPlayer

var hero : Hero
var trigger_held := false
var second_trigger_held := false
var time_since_firing := 0.0
var time_between_shots := 0.0
var damage := 0.0


func _ready() -> void:
	time_between_shots = stats.get_attribute("Fire Delay")
	damage = stats.get_attribute("Damage")


func set_hero(value):
	hero = value


func _process(delta: float) -> void:
	if time_since_firing < time_between_shots:
		time_since_firing += delta


func _physics_process(_delta: float) -> void:
	if trigger_held and time_since_firing >= time_between_shots:
		time_since_firing -= time_between_shots
		shoot()
		networked_shoot.rpc()


func hold_trigger():
	trigger_held = true


func release_trigger():
	trigger_held = false


func hold_second_trigger():
	second_trigger_held = true


func release_second_trigger():
	second_trigger_held = false


func shoot():
	animator.play("shoot")


@rpc
func networked_shoot():
	animator.play("shoot")
