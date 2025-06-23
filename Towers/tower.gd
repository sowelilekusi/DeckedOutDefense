class_name Tower
extends Node3D

@export var turns_to_aim: bool = true
@export var stats: CardText
@export var target_finder: TargetFinder
@export var affector: Affector
@export var animator: AnimationPlayer
@export var pitch_model: MeshInstance3D
@export var yaw_model: MeshInstance3D
@export var range_indicator: CSGSphere3D
@export var audio_player: AudioStreamPlayer3D
@export var effect: Effect

var owner_id: int
var base_name: String
var time_since_firing: float = 0.0
var time_between_shots: float = 0.0
var target_range: float = 0.0

#TODO: there needs to be a proper status effect system for towers
var big_speed_buff_timer: float = 0.0
var small_speed_buff_timer: float = 0.0


func _ready() -> void:
	time_between_shots = stats.get_attribute("Fire Delay")
	effect.damage = int(stats.get_attribute("Damage"))
	target_range = stats.get_attribute("Range")
	range_indicator.radius = target_range if target_range > 0 else 0.1


func preview_range(value: bool) -> void:
	range_indicator.set_visible(value)


func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	if time_since_firing < time_between_shots:
		time_since_firing += delta
		if small_speed_buff_timer > 0.0:
			small_speed_buff_timer -= delta
			time_since_firing += delta * 0.10
		if big_speed_buff_timer > 0.0:
			big_speed_buff_timer -= delta
			time_since_firing += delta * 0.35


func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority():
		#only doing the graphical sort of stuff but not shoot logic 
		if target_finder.targets.size() > 0 && turns_to_aim:
			aim()
		return
	if target_finder.targets.size() > 0:
		#print("value is " + str(target_finder.targets.size() > 0) + ", getter retrieved " + str(target_finder.has_target))
		if turns_to_aim:
			aim()
		if time_since_firing >= time_between_shots:
			time_since_firing -= time_between_shots
			if affector:
				shoot()


func aim() -> void:
	yaw_model.look_at(target_finder.targets[0].global_position)
	pitch_model.look_at(target_finder.targets[0].global_position)
	pitch_model.rotation.x = 0.0


func shoot() -> void:
	affector.apply_effect(effect, target_finder.targets)
	animator.play("shoot")
	audio_player.play()
	if is_multiplayer_authority():
		networked_shoot.rpc()


@rpc("reliable")
func networked_shoot() -> void:
	shoot()
