extends Node3D
class_name EditTool

@export var hero : Hero
@export var inventory : Inventory
@export var ray : RayCast3D
@export var wall_preview : TowerBase
@export var build_preview_material : StandardMaterial3D
@export var progress_bar : TextureProgressBar

var enabled := true
var point_id := -1
var obstacle_last_point := -1
var valid_point := false
var is_looking_at_tower_base := false
var tower_preview
var last_tower_base
var last_card
var ray_collider
var ray_point

var interact_key_held := false
var interacted_once := false
var interact_held_time := 0.0
var interact_hold_time := 0.5


func _ready() -> void:
	wall_preview.set_material(build_preview_material)
	wall_preview.toggle_collision()


func _process(delta: float) -> void:
	if !enabled:
		ray_collider = null
		ray_point = null
		wall_preview.set_visible(false)
		return
	
	if interact_key_held and !interacted_once and valid_point and hero.currency >= Data.wall_cost and ray.is_colliding() and Game.level.a_star_graph_3d.point_is_build_location(point_id):
		interact_held_time += delta
		set_progress_percent(interact_held_time / interact_hold_time)
		if interact_held_time >= interact_hold_time:
			set_progress_percent(0)
			interacted_once = true
			build_wall()
	if !interact_key_held:
		interact_held_time = 0.0
		interacted_once = false
		set_progress_percent(0)
	
	point_id = -1
	if ray.is_colliding():
		if !interact_key_held:
			wall_preview.set_visible(true)
			ray_collider = ray.get_collider()
			ray_point = ray.get_collision_point()
		
		is_looking_at_tower_base = ray_collider is TowerBase
		if is_looking_at_tower_base and inventory.contents.size() > 0 and !ray_collider.has_card:
			if ray_collider != last_tower_base or inventory.selected_item != last_card:
				spawn_tower_preview()
		elif tower_preview:
			delete_tower_preview()
		if Game.level:
			point_id = Game.level.a_star_graph_3d.astar.get_closest_point(ray_point)
			if !Game.level.a_star_graph_3d.point_is_build_location(point_id) or hero.currency < Data.wall_cost:
				wall_preview.set_visible(false)
			else:
				var point_position = Game.level.a_star_graph_3d.astar.get_point_position(point_id)
				wall_preview.global_position = point_position
				wall_preview.global_rotation = Vector3.ZERO
				if obstacle_last_point != point_id:
					obstacle_last_point = point_id
					if Game.level.a_star_graph_3d.test_path_if_point_toggled(point_id):
						build_preview_material.albedo_color = Color.GREEN
						build_preview_material.albedo_color.a = 0.8
						valid_point = true
					else:
						build_preview_material.albedo_color = Color.RED
						build_preview_material.albedo_color.a = 0.8
						valid_point = false
	else:
		ray_collider = null
		ray_point = null
		is_looking_at_tower_base = false
		delete_tower_preview()
		wall_preview.set_visible(false)


func spawn_tower_preview():
	delete_tower_preview()
	last_tower_base = ray_collider
	var card = inventory.selected_item
	last_card = card
	tower_preview = card.turret_scene.instantiate() as Tower
	tower_preview.stats = card.tower_stats
	tower_preview.preview_range(true)
	ray_collider.add_child(tower_preview)


func delete_tower_preview():
	last_tower_base = null
	last_card = null
	if tower_preview:
		tower_preview.queue_free()
		tower_preview = null


func interact():
	if ray_collider is TowerBase:
		var tower_base = ray_collider as TowerBase
		put_card_in_tower_base(tower_base)


func build_wall():
	if point_id >= 0 and valid_point and hero.currency >= Data.wall_cost:
		hero.currency -= Data.wall_cost
		Game.level.a_star_graph_3d.toggle_point(point_id)
	wall_preview.set_visible(false)


func put_card_in_tower_base(tower_base: TowerBase):
	if tower_base.has_card:
		inventory.add(tower_base.remove_card())
	else:
		tower_base.add_card(inventory.remove())


func set_progress_percent(value: float):
	progress_bar.value = progress_bar.max_value * value
