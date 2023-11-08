extends Tower
class_name RocketTower

var targeted_enemies = []
@export var rocket_scene : PackedScene
@export var target_max := 3
var targets = []


func _process(delta: float) -> void:
	other_cooldown -= delta
	if targets.size() < target_max:
		acquire_target()
	if targets.size() > 0:
		var target_list = targets.duplicate()
		for target in target_list:
			if !is_instance_valid(target):
				targets.erase(target)
				continue
			if model.global_position.distance_to(target.global_position) > stats.fire_range:
				targets.erase(target)
		if targets.size() > 0:
			targeted_enemy = targets[0]
			aim()
			if other_cooldown <= 0:
				shoot()
				other_cooldown = cooldown


func shoot():
	for target in targets:
		var rocket = rocket_scene.instantiate() as Rocket
		rocket.position = model.global_position
		rocket.damage = stats.damage
		get_tree().root.add_child(rocket)
		rocket.target = target


func acquire_target():
	var possible_enemies = []
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if model.global_position.distance_to(enemy.global_position) > stats.fire_range:
			continue
		if !(enemy.stats.target_type & stats.can_target):
			continue
		if targets.has(enemy):
			continue
		possible_enemies.append(enemy)
	
	for x in target_max - targets.size():
		if possible_enemies.size() == 0:
			return
		var chosen = possible_enemies.pick_random()
		possible_enemies.erase(chosen)
		targets.append(chosen)
		
