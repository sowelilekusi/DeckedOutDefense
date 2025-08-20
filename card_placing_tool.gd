class_name CardPlacingTool
extends Node3D

@export var hero: Hero
@export var ray: RayCast3D

var enabled: bool = false
var tower_preview: Tower
var tower_preview_card: Card
var last_tower_base: TowerBase
var ray_collider: Object


func reset() -> void:
	delete_tower_preview()


func _process(_delta: float) -> void:
	if !enabled:
		reset()
		return
	
	if !ray_collider or hero.hand.size == 0 or ray_collider.has_card:
		delete_tower_preview()
	
	if ray.is_colliding() and ray.get_collider() is TowerBase:
		ray_collider = ray.get_collider()
		if hero.hand.size > 0 and !ray_collider.has_card:
			if ray_collider != last_tower_base or hero.selected_card != tower_preview_card:
				spawn_tower_preview()
	else:
		ray_collider = null


func interact() -> void:
	if ray.is_colliding() and ray.get_collider() is TowerBase:
		var tower_base: TowerBase = ray.get_collider() as TowerBase
		if hero.game_manager.card_gameplay:
			if hero.hand.size > 0:
				place_card(tower_base)
		else:
			if tower_base.has_card:
				remove_card(tower_base)
			elif hero.hand.size > 0:
				place_card(tower_base)


func place_card(tower_base: TowerBase) -> void:
	var card: Card = hero.selected_card
	var energy_cost: int = card.cost
	if hero.game_manager.card_gameplay and hero.energy < energy_cost:
		return
	remove_card(tower_base)
	hero.hand.remove_at(hero.hand.contents.find(card))
	hero.check_removal()
	tower_base.add_card(card, multiplayer.get_unique_id())
	hero.place_card_audio.play()
	if hero.game_manager.card_gameplay:
		hero.discard_pile.add(card)
		hero.energy -= energy_cost


func remove_card(tower_base: TowerBase) -> void:
	if tower_base.has_card:
		tower_base.remove_card()


func spawn_tower_preview() -> void:
	delete_tower_preview()
	var card: Card = hero.selected_card
	last_tower_base = ray_collider as TowerBase
	tower_preview_card = card
	tower_preview = card.turret_scene.instantiate() as Tower
	tower_preview.stats = card.tower_stats
	tower_preview.position = Vector3.UP
	tower_preview.preview_range(true)
	last_tower_base.add_child(tower_preview)


func delete_tower_preview() -> void:
	last_tower_base = null
	if is_instance_valid(tower_preview):
		tower_preview.queue_free()
		tower_preview = null
		tower_preview_card = null
