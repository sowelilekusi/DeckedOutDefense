extends Node3D
class_name OldTower

@export var model : Node3D
@export var range_sphere : CSGSphere3D
@export var minimap_range_sphere : CSGSphere3D

var targeted_enemy
var cooldown := 0.0
var other_cooldown := 0.0

func _ready() -> void:
	cooldown = 1.0 / stats.fire_rate
	range_sphere.radius = stats.fire_range
	minimap_range_sphere.radius = stats.fire_range
	#minimap_range_sphere.set_visible(true)


func preview_range(value):
	range_sphere.set_visible(value)
	minimap_range_sphere.set_visible(value)


func _process(delta: float) -> void:
	other_cooldown -= delta
	if !targeted_enemy:
		acquire_target()
	else:
		if model.global_position.distance_to(targeted_enemy.global_position) > stats.fire_range:
			targeted_enemy = null
		if targeted_enemy:
			aim()
			if other_cooldown <= 0:
				shoot()
				other_cooldown = cooldown


func shoot():
	targeted_enemy.damage(stats.damage)


func aim():
	model.look_at(targeted_enemy.global_position)


func acquire_target():
	var most_progressed_enemy = null
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if model.global_position.distance_to(enemy.global_position) > stats.fire_range:
			continue
		var em_1 = enemy.movement_controller as EnemyMovement
		var em_2 : EnemyMovement
		if most_progressed_enemy != null:
			em_2 = most_progressed_enemy.movement_controller as EnemyMovement
		if (most_progressed_enemy == null or em_1.distance_remaining < em_2.distance_remaining) and enemy.stats.target_type & stats.can_target:
			most_progressed_enemy = enemy
	if most_progressed_enemy != null:
		targeted_enemy = most_progressed_enemy