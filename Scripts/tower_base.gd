extends StaticBody3D
class_name TowerBase

@export var inventory : Inventory
@export var block : CSGBox3D
@export var collider : CollisionShape3D
@export var minimap_icon : Sprite3D

var tower = null
var has_card : bool :
	set(_value):
		return
	get:
		return inventory.contents.size() != 0


func add_card(card: Card) -> bool:
	var result = inventory.add(card)
	if result:
		networked_spawn_tower.rpc()
	return result


func remove_card() -> Card:
	networked_remove_tower.rpc()
	return inventory.remove()


func set_material(value: StandardMaterial3D):
	block.material = value


func toggle_collision():
	collider.disabled = !collider.disabled


@rpc("reliable", "call_local", "any_peer")
func networked_spawn_tower():
	tower = inventory.selected_item.turret_scene.instantiate() as Tower
	tower.stats = inventory.selected_item.tower_stats
	tower.name = "tower"
	tower.base_name = name
	tower.position = Vector3.UP
	minimap_icon.modulate = Color.RED
	add_child(tower)


@rpc("reliable", "call_local", "any_peer")
func networked_remove_tower():
	tower.queue_free()
	tower = null
	minimap_icon.modulate = Color.GREEN
