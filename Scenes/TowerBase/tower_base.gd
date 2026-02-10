class_name TowerBase extends StaticBody3D

@export var inventory: Inventory
@export var block: Node3D
@export var collider: CollisionShape3D
@export var minimap_icon: Sprite3D
@export var duration_label: Label
@export var duration_sprites: Array[Sprite3D] = []

var game_manager: GameManager
var owner_id: int
var point: FlowNodeData
var tower: Tower = null
var has_card: bool :
	set(_value):
		return
	get:
		return inventory.size != 0
var duration: int = 0 : 
	set(value):
		duration = value
		duration_label.text = str(value)
	get():
		return duration


func set_color(color: Color) -> void:
	$MeshInstance3D.material_override.set("shader_parameter/Color", color)


func set_float(value: float) -> void:
	$MeshInstance3D.material_override.set("shader_parameter/Float", value)


@rpc("reliable", "call_local", "any_peer")
func networked_spawn_tower(card_index: int, caller_id: int) -> void:
	var card: Card = Data.cards[card_index]
	inventory.add(card)
	tower = inventory.item_at(0).turret_scene.instantiate() as Tower
	tower.stats = inventory.item_at(0).tower_stats
	tower.name = "tower"
	tower.base_name = name
	tower.owner_id = caller_id
	tower.position = Vector3(0, 1.2, 0)
	minimap_icon.modulate = Color.RED
	duration = 999
	add_child(tower)


@rpc("reliable", "call_local", "any_peer")
func networked_remove_tower() -> void:
	var card: Card = inventory.remove_at(0)
	if !game_manager.card_gameplay:
		game_manager.connected_players_nodes[tower.owner_id].add_card(card)
		game_manager.connected_players_nodes[tower.owner_id].unready_self()
	tower.queue_free()
	tower = null
	minimap_icon.modulate = Color.GREEN


func toggle_collision() -> void:
	collider.disabled = !collider.disabled


func iterate_duration() -> void:
	duration -= 1
	if duration <= 0:
		networked_remove_tower.rpc()


func enable_duration_sprites() -> void:
	for sprite: Sprite3D in duration_sprites:
		sprite.visible = true


func disable_duration_sprites() -> void:
	for sprite: Sprite3D in duration_sprites:
		sprite.visible = false
