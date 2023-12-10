extends StaticBody3D
class_name TowerBase

@export var inventory : Inventory
@export var block : Node3D
@export var collider : CollisionShape3D
@export var minimap_icon : Sprite3D
@export var north_icon : Sprite3D
@export var south_icon : Sprite3D
@export var east_icon : Sprite3D
@export var west_icon : Sprite3D
@export var north_mesh : CSGBox3D
@export var south_mesh : CSGBox3D
@export var east_mesh : CSGBox3D
@export var west_mesh : CSGBox3D
@export var north_collider : CollisionShape3D
@export var south_collider : CollisionShape3D
@export var east_collider : CollisionShape3D
@export var west_collider : CollisionShape3D

var owner_id : int
var point_id : int
var tower = null
var has_card : bool :
	set(_value):
		return
	get:
		return inventory.contents.size() != 0


func set_color(color: Color):
	$MeshInstance3D.set_instance_shader_parameter("Color", color)


func set_float(value: float):
	$MeshInstance3D.set_instance_shader_parameter("Float", value)


func add_card(card: Card, caller_id: int) -> bool:
	var result = inventory.add(card)
	if result:
		networked_spawn_tower.rpc(caller_id)
	return result


func remove_card():
	Game.connected_players_nodes[tower.owner_id].add_card(inventory.remove())
	networked_remove_tower.rpc()


func toggle_collision():
	collider.disabled = !collider.disabled


func set_north_wall(value: bool):
	north_mesh.set_visible(value)
	north_collider.disabled = !value


func set_south_wall(value : bool):
	south_mesh.set_visible(value)
	south_collider.disabled = !value


func set_east_wall(value : bool):
	east_mesh.set_visible(value)
	east_collider.disabled = !value


func set_west_wall(value : bool):
	west_mesh.set_visible(value)
	west_collider.disabled = !value


@rpc("reliable", "call_local", "any_peer")
func networked_spawn_tower(caller_id : int):
	tower = inventory.selected_item.turret_scene.instantiate() as Tower
	tower.stats = inventory.selected_item.tower_stats
	tower.name = "tower"
	tower.base_name = name
	tower.owner_id = caller_id
	tower.position = Vector3(0, 1.2, 0)
	minimap_icon.modulate = Color.RED
	north_icon.modulate = Color.RED
	south_icon.modulate = Color.RED
	west_icon.modulate = Color.RED
	east_icon.modulate = Color.RED
	add_child(tower)


@rpc("reliable", "call_local", "any_peer")
func networked_remove_tower():
	tower.queue_free()
	tower = null
	minimap_icon.modulate = Color.GREEN
	north_icon.modulate = Color.GREEN
	south_icon.modulate = Color.GREEN
	west_icon.modulate = Color.GREEN
	east_icon.modulate = Color.GREEN
