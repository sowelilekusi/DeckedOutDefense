class_name PathingController extends EnemyMovement

#var path: Curve3D
#var path_progress: float = 0.0
var flow_field: FlowField
var next_node: FlowNode


func _ready() -> void:
	#if path:
	#	distance_remaining = path.get_baked_length()
	next_node = flow_field.get_closest_traversable_point(character.global_position)
	distance_remaining += calculate_distance_to_goal(next_node)


func calculate_distance_to_goal(node: FlowNode) -> float:
	var distance: float = 0.0
	distance += character.global_position.distance_to(node.global_position)
	if node.best_path:
		var then_next_node: FlowNode = node.best_path
		distance += node.global_position.distance_to(then_next_node.global_position)
		while then_next_node.best_path:
			distance += then_next_node.global_position.distance_to(then_next_node.best_path.global_position)
			then_next_node = then_next_node.best_path
	return distance


func walk(delta: float) -> void:
	var distance_travelled: float = (character.stats.movement_speed * clampf(character.movement_speed_penalty, 0.0, 1.0)) * delta
	distance_remaining -= distance_travelled
	character.global_position = character.global_position.move_toward(next_node.global_position, distance_travelled)
	character.look_at(next_node.global_position)
	if character.global_position.distance_to(next_node.global_position) <= 0.05:
		next_node = next_node.best_path


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
