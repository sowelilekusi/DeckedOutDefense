extends Node3D
class_name Tower

@export var stats : CardText
@export var animator : AnimationPlayer
@export var pitch_model : MeshInstance3D
@export var yaw_model : MeshInstance3D
@export var range_indicator : CSGSphere3D

var damage_particle_scene = preload("res://Scenes/damage_particle.tscn")
var base_name
var targeted_enemy
var time_since_firing := 0.0
var time_between_shots := 0.0
var damage := 0.0
var target_range := 0.0


func _ready() -> void:
	time_between_shots = stats.get_attribute("Fire Delay")
	damage = stats.get_attribute("Damage")
	target_range = stats.get_attribute("Range")
	range_indicator.radius = target_range


func preview_range(value):
	range_indicator.set_visible(value)


func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	if time_since_firing < time_between_shots:
		time_since_firing += delta


func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority():
		#only doing the graphical sort of stuff but not shoot logic 
		if targeted_enemy:
			if !is_instance_valid(targeted_enemy) or !targeted_enemy.alive or global_position.distance_to(targeted_enemy.global_position) > target_range:
				targeted_enemy = null
			else:
				aim()
		return
	if !targeted_enemy:
		acquire_target()
	else:
		if !is_instance_valid(targeted_enemy) or !targeted_enemy.alive or global_position.distance_to(targeted_enemy.global_position) > target_range:
			targeted_enemy = null
		if targeted_enemy:
			aim()
			if time_since_firing >= time_between_shots:
				time_since_firing -= time_between_shots
				shoot()


func aim():
	yaw_model.look_at(targeted_enemy.global_position)
	pitch_model.look_at(targeted_enemy.global_position)
	pitch_model.rotation.x = 0.0


func acquire_target():
	var most_progressed_enemy = null
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if global_position.distance_to(enemy.global_position) > target_range:
			continue
		var em_1 = enemy.movement_controller as EnemyMovement
		var em_2 : EnemyMovement
		if most_progressed_enemy != null:
			em_2 = most_progressed_enemy.movement_controller as EnemyMovement
		if (most_progressed_enemy == null or em_1.distance_remaining < em_2.distance_remaining) and enemy.stats.target_type & stats.target_type:
			most_progressed_enemy = enemy
	if most_progressed_enemy != null:
		targeted_enemy = most_progressed_enemy
		networked_acquire_target.rpc(get_tree().root.get_path_to(most_progressed_enemy))


func shoot():
	animator.play("shoot")
	if is_multiplayer_authority():
		networked_shoot.rpc()


func spawn_damage_indicator(pos):
	if damage > 0:
		var marker = damage_particle_scene.instantiate()
		get_tree().root.add_child(marker)
		marker.set_number(damage)
		marker.position = pos


@rpc("reliable")
func networked_shoot():
	shoot()


@rpc("reliable")
func networked_acquire_target(target_node_path):
	targeted_enemy = get_tree().root.get_node(target_node_path)
