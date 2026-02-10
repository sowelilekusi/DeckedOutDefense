class_name PathingController
extends EnemyMovement

var random_points_generated: int
var flow_field: FlowField
var next_node: FlowNodeData : 
	get():
		return next_node
	set(value):
		next_node = value
		if next_node == null:
			return
		var found_point: bool = false
		while !found_point:
			random_points_generated += 1
			var sample: int = random_points_generated + character.name.to_int()
			var r: float = 1.0 * sqrt(NoiseRandom.randf_in_range(sample, 0.0, 1.0))
			var theta: float = NoiseRandom.randf_in_range(sample * 4, 0.0, 1.0) * 2.0 * PI
			var x: float = r * cos(theta)
			var y: float = r * sin(theta)
			if Vector3(next_node.position.x + x, next_node.position.y, next_node.position.z + y).distance_to(next_node.position) <= 1.0:
				found_point = true
				next_pos = Vector3(next_node.position.x + x, next_node.position.y, next_node.position.z + y)
var next_pos: Vector3


func _ready() -> void:
	super._ready()
	if flow_field:
		next_node = flow_field.get_closest_point(character.global_position, true, false)
		#We skip one node so the "start" nodes placed near
		#spawners are just usefull for "catching" enemies that are looking
		#for a way into the pathfinding graph
		next_node = next_node.best_path
		distance_remaining += calculate_distance_to_goal(next_node)


func calculate_distance_to_goal(node: FlowNodeData) -> float:
	var distance: float = 0.0
	distance += character.global_position.distance_to(node.position)
	if node.best_path:
		var then_next_node: FlowNodeData = node.best_path
		distance += node.position.distance_to(then_next_node.position)
		while then_next_node.best_path:
			distance += then_next_node.position.distance_to(then_next_node.best_path.position)
			then_next_node = then_next_node.best_path
	return distance


func walk(delta: float) -> void:
	var distance_travelled: float = (speed * clampf(speed, 0.0, 1.0)) * delta
	distance_remaining -= distance_travelled
	character.global_position = character.global_position.move_toward(next_pos, distance_travelled)
	var distance_to_next_pos: float = character.global_position.distance_to(next_pos)
	if distance_to_next_pos <= 0.05:
		next_node = next_node.best_path
	else:
		character.look_at(next_pos)


func _physics_process(delta: float) -> void:
	#if !path:
	#	return
	if !next_node:
		return
	walk(delta)
	#path_progress += distance_travelled
	#var sample: Transform3D = path.sample_baked_with_rotation(path_progress, true)
	#character.global_position = sample.origin
	#character.look_at(character.global_position + -sample.basis.z)
	#var closest_point: Vector3 = path.get_closest_point(character.global_position)
