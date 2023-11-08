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
		tower = card.turret.instantiate() as Tower
		tower.stats = card.tower_stats
		minimap_icon.modulate = Color.RED
		add_child(tower)
	return result


func remove_card() -> Card:
	tower.queue_free()
	tower = null
	minimap_icon.modulate = Color.GREEN
	return inventory.remove()


func set_material(value: StandardMaterial3D):
	block.material = value


func toggle_collision():
	collider.disabled = !collider.disabled
