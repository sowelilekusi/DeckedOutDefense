class_name PathEditTool
extends Node3D

@export var hero: Hero
@export var ray: RayCast3D
@export var wall_preview: TowerBase
@export var progress_bar: TextureProgressBar

var enabled: bool = false
var level: Level
var point: FlowNode
var obstacle_last_point: int = -1
var valid_point: bool = false # a point is valid if the path would still be traversable overall if this point was made untraversable
var ray_collider: Object
var ray_point: Vector3
var last_point: FlowNode
var last_tower_base: TowerBase
var interact_key_held: bool = false
var interacted_once: bool = false
var interact_held_time: float = 0.0
var interact_hold_time: float = 0.4


func _ready() -> void:
	var c: Color = Color.GREEN
	c.a = 0.8
	wall_preview.set_color(c)
	wall_preview.set_float(0.0)
	wall_preview.toggle_collision()


func _process(delta: float) -> void:
	if !enabled:
		reset()
		return
	
	if interact_key_held:
		if !interacted_once:
			if valid_point and hero.energy >= Data.wall_cost and ray_collider and point.buildable:
				interact_held_time += delta
				set_progress_percent(interact_held_time / interact_hold_time)
				wall_preview.set_float(interact_held_time / interact_hold_time)
				if interact_held_time >= interact_hold_time:
					set_progress_percent(0)
					interacted_once = true
					build_wall()
			elif ray_collider is TowerBase:
				interact_held_time += delta
				set_progress_percent(interact_held_time / interact_hold_time)
				if interact_held_time >= interact_hold_time:
					set_progress_percent(0)
					interacted_once = true
					refund_wall(ray_collider)
	else:
		interact_held_time = 0.0
		interacted_once = false
		set_progress_percent(0)
		wall_preview.set_float(0.0)
	
	if !interacted_once and ray.is_colliding():
		#if statement makes sure once the building animation has started then
		#the position the wall builds in is already decided and moving the mouse
		#around isnt going to make the resulting
		#wall teleport to the new mouse location
		if !interact_key_held:
			wall_preview.set_visible(true)
			if is_instance_valid(ray_collider) and ray_collider is TowerBase:
				level.walls[ray_collider.point].set_float(1.0)
			ray_collider = ray.get_collider()
			ray_point = ray.get_collision_point()
		
		if ray_collider is TowerBase:
			process_looking_at_tower()
		elif level:
			process_looking_at_level()
	elif !interact_key_held:
		reset()
	if !valid_point:
		wall_preview.set_visible(false)
	if point:
		wall_preview.global_position = point.global_position
		wall_preview.global_rotation = Vector3.ZERO


func reset() -> void:
	if is_instance_valid(ray_collider) and ray_collider is TowerBase and level.walls.has(ray_collider.point):
		level.walls[ray_collider.point].set_float(1.0)
	ray_collider = null
	wall_preview.set_visible(false)
	clear_previous_point()
	last_point = null


func process_looking_at_level() -> void:
	point = level.flow_field.get_closest_buildable_point(ray_point)
	if level.walls.has(point) or !point.buildable or hero.energy < Data.wall_cost:
		wall_preview.set_visible(false)
		valid_point = false
		clear_previous_point()
		last_point = point
	else:
		if last_point != point:
			clear_previous_point()
			last_point = point
			if !level.walls.has(point) and level.flow_field.traversable_after_blocking_point(point):
				level.flow_field.toggle_traversable(point)
				wall_preview.set_float(0.0)
				valid_point = true
			else:
				valid_point = false


func clear_previous_point() -> void:
	if last_point and !level.walls.has(last_point) and !last_point.traversable:
		level.flow_field.toggle_traversable(last_point)


func process_looking_at_tower() -> void:
	valid_point = false
	point = ray_collider.point
	if last_point != point:
		clear_previous_point()
	
	wall_preview.set_visible(false)
	ray_collider.set_color(Color.RED)
	ray_collider.set_float(0.0)


func build_wall() -> void:
	if point and valid_point and hero.energy >= Data.wall_cost:
		hero.energy -= Data.wall_cost
		level.set_wall(point, multiplayer.get_unique_id())
	wall_preview.visible = false


func refund_wall(wall: TowerBase) -> void:
	if !is_instance_valid(wall):
		return
	if wall.has_card:
		wall.remove_card()
	level.remove_wall(wall.point)


func set_progress_percent(value: float) -> void:
	progress_bar.value = progress_bar.max_value * value
