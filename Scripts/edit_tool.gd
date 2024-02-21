class_name EditTool extends Node3D

@export var hero: Hero
@export var inventory: Inventory
@export var ray: RayCast3D
@export var wall_preview: TowerBase
@export var progress_bar: TextureProgressBar

var enabled: bool = true
var point_id: int = -1
var obstacle_last_point: int = -1
var valid_point: bool = false
var is_looking_at_tower_base: bool = false
var tower_preview: Tower
var last_tower_base: TowerBase
var last_collider: Object
var last_card: Card
var ray_collider: Object
var ray_point: Vector3

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
		ray_collider = null
		wall_preview.set_visible(false)
		if is_instance_valid(last_collider):
			Game.level.a_star_graph_3d.tower_base_ids[last_collider.point_id].set_float(1.0)
			last_collider = null
		return
	
	if interact_key_held and !interacted_once and valid_point and hero.currency >= Data.wall_cost and ray.is_colliding() and Game.level.a_star_graph_3d.point_is_build_location(point_id):
		interact_held_time += delta
		set_progress_percent(interact_held_time / interact_hold_time)
		wall_preview.set_float(interact_held_time / interact_hold_time)
		if interact_held_time >= interact_hold_time:
			set_progress_percent(0)
			interacted_once = true
			build_wall()
	if interact_key_held and !interacted_once and last_collider and ray.is_colliding():
		interact_held_time += delta
		set_progress_percent(interact_held_time / interact_hold_time)
		if interact_held_time >= interact_hold_time:
			set_progress_percent(0)
			interacted_once = true
			refund_wall(last_collider)
	if !interact_key_held:
		interact_held_time = 0.0
		interacted_once = false
		set_progress_percent(0)
		wall_preview.set_float(0.0)
	
	point_id = -1
	if !interacted_once and ray.is_colliding():
		if !interact_key_held:
			wall_preview.set_visible(true)
			ray_collider = ray.get_collider()
			ray_point = ray.get_collision_point()
		
		is_looking_at_tower_base = ray_collider is TowerBase
		if is_looking_at_tower_base:
			valid_point = false
			point_id = ray_collider.point_id
			if obstacle_last_point != point_id:
				obstacle_last_point = point_id
				if is_instance_valid(last_collider):
					Game.level.a_star_graph_3d.tower_base_ids[last_collider.point_id].set_float(1.0)
					last_collider = null
			if tower_preview:
				delete_tower_preview()
			wall_preview.set_visible(false)
			last_collider = ray_collider
			ray_collider.set_color(Color.RED)
			ray_collider.set_float(0.0)
			if inventory.contents.size() > 0 and !ray_collider.has_card:
				if ray_collider != last_tower_base or inventory.selected_item != last_card:
					spawn_tower_preview()
		elif Game.level:
			if is_instance_valid(last_collider):
				Game.level.a_star_graph_3d.tower_base_ids[last_collider.point_id].set_float(1.0)
				last_collider = null
			if tower_preview:
				delete_tower_preview()
			point_id = Game.level.a_star_graph_3d.astar.get_closest_point(ray_point)
			if !Game.level.a_star_graph_3d.point_is_build_location(point_id) or hero.currency < Data.wall_cost:
				wall_preview.set_visible(false)
			else:
				var point_position: Vector3 = Game.level.a_star_graph_3d.astar.get_point_position(point_id)
				wall_preview.global_position = point_position
				wall_preview.global_rotation = Vector3.ZERO
				if obstacle_last_point != point_id:
					obstacle_last_point = point_id
					if Game.level.a_star_graph_3d.test_path_if_point_toggled(point_id):
						var c: Color = Color.GREEN
						c.a = 0.8
						wall_preview.set_color(c)
						wall_preview.set_float(0.0)
						valid_point = true
					else:
						#build_preview_material.albedo_color = Color.RED
						#build_preview_material.albedo_color.a = 0.8
						valid_point = false
	else:
		ray_collider = null
		is_looking_at_tower_base = false
		delete_tower_preview()
		wall_preview.set_visible(false)
	if !valid_point:
		wall_preview.set_visible(false)


func spawn_tower_preview() -> void:
	delete_tower_preview()
	last_tower_base = ray_collider
	var card: Card = inventory.contents.keys()[hero.inventory_selected_index]
	last_card = card
	tower_preview = card.turret_scene.instantiate() as Tower
	tower_preview.stats = card.tower_stats
	tower_preview.position = Vector3.UP
	tower_preview.preview_range(true)
	ray_collider.add_child(tower_preview)


func delete_tower_preview() -> void:
	last_tower_base = null
	last_card = null
	if is_instance_valid(tower_preview):
		tower_preview.queue_free()
		tower_preview = null


func interact() -> void:
	if ray_collider is TowerBase:
		var tower_base: TowerBase = ray_collider as TowerBase
		put_card_in_tower_base(tower_base)


func build_wall() -> void:
	if point_id >= 0 and valid_point and hero.currency >= Data.wall_cost:
		hero.currency -= Data.wall_cost
		Game.level.a_star_graph_3d.toggle_point(point_id, multiplayer.get_unique_id())
	wall_preview.set_visible(false)


func refund_wall(wall: TowerBase) -> void:
	last_collider = null
	if wall.has_card:
		wall.remove_card()
	Game.level.a_star_graph_3d.remove_wall(wall)


func put_card_in_tower_base(tower_base: TowerBase) -> void:
	if tower_base.has_card:
		tower_base.remove_card()
	else:
		var card: Card = inventory.remove_at(hero.inventory_selected_index)
		if !inventory.contents.has(card):
			hero.decrement_selected()
		tower_base.add_card(card, multiplayer.get_unique_id())


func set_progress_percent(value: float) -> void:
	progress_bar.value = progress_bar.max_value * value
