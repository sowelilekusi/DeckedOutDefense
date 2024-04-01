class_name Tower extends Node3D

@export var stats: CardText
@export var target_finder: TargetFinder
@export var animator: AnimationPlayer
@export var pitch_model: MeshInstance3D
@export var yaw_model: MeshInstance3D
@export var range_indicator: CSGSphere3D
@export var audio_player: AudioStreamPlayer3D

var owner_id: int
var damage_particle_scene: PackedScene = preload("res://Scenes/damage_particle.tscn")
var base_name: String
#var targeted_enemy: EnemyController
var time_since_firing: float = 0.0
var time_between_shots: float = 0.0
var damage: float = 0.0
var target_range: float = 0.0


func _ready() -> void:
	time_between_shots = stats.get_attribute("Fire Delay")
	damage = stats.get_attribute("Damage")
	target_range = stats.get_attribute("Range")
	range_indicator.radius = target_range


func preview_range(value: bool) -> void:
	range_indicator.set_visible(value)


func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	if time_since_firing < time_between_shots:
		time_since_firing += delta


func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority():
		#only doing the graphical sort of stuff but not shoot logic 
		if target_finder.get_target():
			aim()
		return
	if target_finder.get_target():
		aim()
		if time_since_firing >= time_between_shots:
			time_since_firing -= time_between_shots
			shoot()


func aim() -> void:
	yaw_model.look_at(target_finder.get_target().global_position)
	pitch_model.look_at(target_finder.get_target().global_position)
	pitch_model.rotation.x = 0.0


func shoot() -> void:
	animator.play("shoot")
	audio_player.play()
	if is_multiplayer_authority():
		networked_shoot.rpc()


func spawn_damage_indicator(pos: Vector3) -> void:
	if damage > 0:
		var marker: Sprite3D = damage_particle_scene.instantiate()
		get_tree().root.add_child(marker)
		marker.set_number(damage)
		marker.position = pos


@rpc("reliable")
func networked_shoot() -> void:
	shoot()


#@rpc("reliable")
#func networked_acquire_target(target_node_path: String) -> void:
	#targeted_enemy = get_tree().root.get_node(target_node_path)
