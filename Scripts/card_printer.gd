class_name CardPrinter extends StaticBody3D

@export var cards: Array[CardInHand]
@export var item_card_scene: PackedScene
@export var button_collider: CollisionShape3D
@export var button_box: Node3D
@export var choice_colliders: Array[CollisionShape3D]

var card_available: bool = false


func randomize_cards() -> void:
	var weight_total: int = 0
	for rarity: String in Data.Rarity:
		weight_total += Data.rarity_weights[rarity]
	
	var generated_rarity: int = randi_range(0, weight_total)
	var decided_rarity: int = 0
	
	for rarity: String in Data.Rarity:
		weight_total -= Data.rarity_weights[rarity]
		if generated_rarity >= weight_total:
			decided_rarity = Data.Rarity[rarity]
			break
			
	var card_array: Array = []
	for x: Card in Data.cards:
		if x.rarity == decided_rarity:
			card_array.append(x)
	var card: Card
	for x: CardInHand in cards:
		if card_array.size() > 0:
			card = card_array.pick_random()
			card_array.erase(card)
		x.set_card(card)
		#TODO: in reality this should just show the icon and then hovering over it lets you see either side at the players own discretion
		x.view_tower()
	$Node3D.set_visible(true)
	for x: CollisionShape3D in choice_colliders:
		x.disabled = false
	card_available = true


func retrieve_card(i: int) -> void:
	$Node3D.set_visible(false)
	for x: CollisionShape3D in choice_colliders:
		x.disabled = true
	if card_available:
		var card: Card = cards[i].stats
		var item: ItemCard = item_card_scene.instantiate() as ItemCard
		item.card = card
		item.position = Vector3(1.683, 0, 0)
		add_child(item)
	button_collider.disabled = false
	button_box.position = Vector3(0,0,0)
	$AudioStreamPlayer3D.play()


func _on_static_body_3d_button_interacted(_value: int) -> void:
	button_collider.disabled = true
	button_box.position = Vector3(0,0,-0.2)
	$AudioStreamPlayer3D.play()
	randomize_cards()
