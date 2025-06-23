class_name LeapingController
extends PathingController

@export var eastl: Label
@export var westl: Label
@export var northl: Label
@export var southl: Label
@export var easts: Sprite3D
@export var wests: Sprite3D
@export var norths: Sprite3D
@export var souths: Sprite3D
@export var box: CSGBox3D
@export var tol: Label
@export var jump_distance: float = 4.0

var tolerance: float = 50.0
var jumping: bool = false


func _process(delta: float) -> void:
	tolerance = remap(character.health.current_health, character.health.max_health * 0.20, character.health.max_health, 10, 50)
	tolerance = maxf(tolerance, 10)


func _physics_process(delta: float) -> void:
	if !next_node or jumping:
		return
	walk(delta)
	consider_leap(Vector3.FORWARD)
	consider_leap(Vector3.LEFT)
	consider_leap(Vector3.BACK)
	consider_leap(Vector3.RIGHT)
	#var closest_point: int = astar.astar.get_closest_point(character.global_position, false)
	#box.global_position = astar.astar.get_point_position(closest_point)
	#var east: int = astar.get_east_point(closest_point)
	#var west: int = astar.get_west_point(closest_point)
	#var north: int = astar.get_north_point(closest_point)
	#var south: int = astar.get_south_point(closest_point)
	#if east >= 0 and astar.astar.is_point_disabled(east):
		#eastl.text = "fuck no"
	#else:
		#eastl.text = "yeah"
	#if west >= 0 and astar.astar.is_point_disabled(west):
		#westl.text = "fuck no"
	#else:
		#westl.text = "yeah"
	#if north >= 0 and astar.astar.is_point_disabled(north):
		#northl.text = "fuck no"
	#else:
		#northl.text = "yeah"
	#if south >= 0 and astar.astar.is_point_disabled(south):
		#southl.text = "fuck no"
	#else:
		#southl.text = "yeah"
	#norths.global_position = character.global_position + Vector3(-1.0, 1.0, 0.0)
	#souths.global_position = character.global_position + Vector3(1.0, 1.0, 0.0)
	#easts.global_position = character.global_position + Vector3(0.0, 1.0, -1.0)
	#wests.global_position = character.global_position + Vector3(0.0, 1.0, 1.0)
	
		
	
	#if east >= 0:
		#if astar.astar.is_point_disabled(east):
			#var further_point: int = astar.get_east_point(east)
			#if further_point >= 0 and !astar.astar.is_point_disabled(further_point):
				#var expected_offset: float = path.get_closest_offset(character.global_position + Vector3(0.0, 0.0, -4.0))
				#var current_offset: float = path.get_closest_offset(character.global_position)
				#var gain: float = expected_offset - current_offset
				#if gain >= tolerance:
					#distance_remaining -= gain
					##path_progress += gain
					#leap(Vector3(0.0, 0.0, -4.0))
				#eastl.text = str(gain)
				##easts.visible = true
			#else:
				#eastl.text = "cant"
		#else:
			#eastl.text = "clear"
	#else:
		#eastl.text = "invalid"
	#if west >= 0:
		#if astar.astar.is_point_disabled(west):
			#var further_point: int = astar.get_west_point(west)
			#if further_point >= 0 and !astar.astar.is_point_disabled(further_point):
				#var expected_offset: float = path.get_closest_offset(character.global_position + Vector3(0.0, 0.0, 4.0))
				#var current_offset: float = path.get_closest_offset(character.global_position)
				#var gain: float = expected_offset - current_offset
				#if gain >= tolerance:
					#distance_remaining -= gain
					##path_progress += gain
					#leap(Vector3(0.0, 0.0, 4.0))
				#westl.text = str(gain)
				##wests.visible = true
			#else:
				#westl.text = "cant"
		#else:
			#westl.text = "clear"
	#else:
		#westl.text = "invalid"
	#if north >= 0:
		#if astar.astar.is_point_disabled(north):
			#var further_point: int = astar.get_north_point(north)
			#if further_point >= 0 and !astar.astar.is_point_disabled(further_point):
				#var expected_offset: float = path.get_closest_offset(character.global_position + Vector3(-4.0, 0.0, 0.0))
				#var current_offset: float = path.get_closest_offset(character.global_position)
				#var gain: float = expected_offset - current_offset
				#if gain >= tolerance:
					#distance_remaining -= gain
					##path_progress += gain
					#leap(Vector3(-4.0, 0.0, 0.0))
				#northl.text = str(gain)
				##norths.visible = true
			#else:
				#northl.text = "cant"
		#else:
			#northl.text = "clear"
	#else:
		#northl.text = "invalid"
	#if south >= 0:
		#if astar.astar.is_point_disabled(south):
			#var further_point: int = astar.get_south_point(south)
			#if further_point >= 0 and !astar.astar.is_point_disabled(further_point):
				#var expected_offset: float = path.get_closest_offset(character.global_position + Vector3(4.0, 0.0, 0.0))
				#var current_offset: float = path.get_closest_offset(character.global_position)
				#var gain: float = expected_offset - current_offset
				#if gain >= tolerance:
					#distance_remaining -= gain
					##path_progress += gain
					#leap(Vector3(4.0, 0.0, 0.0))
				#southl.text = str(gain)
				##souths.visible = true
			#else:
				#southl.text = "cant"
		#else:
			#southl.text = "clear"
	#else:
		#southl.text = "invalid"


func consider_leap(direction: Vector3) -> void:
	var node: FlowNode = check_jump(character.global_position + (direction * jump_distance))
	if node:
		var expected_distance_remaining: float = calculate_distance_to_goal(node)
		expected_distance_remaining += (character.global_position + (direction * jump_distance)).distance_to(node.global_position)
		var gain: float = distance_remaining - expected_distance_remaining
		if gain >= tolerance:
			distance_remaining -= gain
			leap(direction * jump_distance)
			next_node = node


func finish_jump() -> void:
	jumping = false


func check_jump(destination: Vector3) -> FlowNode:
	var closest_point: FlowNode = flow_field.get_closest_traversable_point(destination)
	if !closest_point.best_path or closest_point.global_position.distance_to(destination) > 1.2:
		return null
	return closest_point.best_path


func leap(to_point: Vector3) -> void:
	jumping = true
	var tween: Tween = create_tween()
	tween.tween_property(character, "global_position", character.global_position + (to_point / 2.0) + Vector3.UP, 0.3)
	tween.tween_property(character, "global_position", character.global_position + to_point, 0.3)
	tween.tween_callback(finish_jump)
