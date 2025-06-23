class_name TowerBase extends StaticBody3D

@export var inventory: Inventory
@export var block: Node3D
@export var collider: CollisionShape3D
@export var minimap_icon: Sprite3D

var game_manager: GameManager
var owner_id: int
var point: FlowNode
var tower: Tower = null
var has_card: bool :
	set(_value):
		return
	get:
		return inventory.size != 0


func set_color(color: Color) -> void:
	$MeshInstance3D.material_override.set("shader_parameter/Color", color)


func set_float(value: float) -> void:
	$MeshInstance3D.material_override.set("shader_parameter/Float", value)


func add_card(card: Card, caller_id: int) -> void:
	networked_spawn_tower.rpc(Data.cards.find(card), caller_id)


func remove_card() -> void:
	networked_remove_tower.rpc()


func toggle_collision() -> void:
	collider.disabled = !collider.disabled


@rpc("reliable", "call_local", "any_peer")
func networked_spawn_tower(card_index: int, caller_id: int) -> void:
	var card: Card = Data.cards[card_index]
	inventory.add(card)
	tower = inventory.contents.keys()[0].turret_scene.instantiate() as Tower
	tower.stats = inventory.contents.keys()[0].tower_stats
	tower.name = "tower"
	tower.base_name = name
	tower.owner_id = caller_id
	tower.position = Vector3(0, 1.2, 0)
	minimap_icon.modulate = Color.RED
	add_child(tower)


@rpc("reliable", "call_local", "any_peer")
func networked_remove_tower() -> void:
	game_manager.connected_players_nodes[tower.owner_id].add_card(inventory.remove_at(0))
	game_manager.connected_players_nodes[tower.owner_id].unready_self()
	tower.queue_free()
	tower = null
	minimap_icon.modulate = Color.GREEN
