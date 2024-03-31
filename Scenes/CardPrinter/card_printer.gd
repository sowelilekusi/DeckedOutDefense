class_name CardPrinter extends StaticBody3D

@export var cards: Array[CardInHand]
@export var item_card_scene: PackedScene
@export var button_collider: CollisionShape3D
@export var button_box: Node3D
@export var choice_colliders: Array[CollisionShape3D]

var cards_generated: int = 0
var card_available: bool = false
var reply_player: Hero


func generate_rarity() -> int:
	var weight_total: int = 0
	for rarity: String in Data.Rarity:
		weight_total += Data.rarity_weights[rarity]
	
	var generated_rarity: int = Game.randi_in_range(4 * cards_generated, 0, weight_total)
	cards_generated += 1
	var decided_rarity: int = 0
	
	for rarity: String in Data.Rarity:
		weight_total -= Data.rarity_weights[rarity]
		if generated_rarity >= weight_total:
			decided_rarity = Data.Rarity[rarity]
			break
	return decided_rarity


func randomize_cards() -> void:
	var decided_rarity: int = generate_rarity()
	var card_array: Array = []
	for x: Card in Data.cards:
		if x.rarity == decided_rarity:
			card_array.append(x)
	var card: Card
	for x: CardInHand in cards:
		if card_array.size() > 0:
			card = card_array[Game.randi_in_range(132 * cards_generated, 0, card_array.size() - 1)]
			cards_generated += 1
			card_array.erase(card)
		x.set_card(card)
		#TODO: in reality this should just show the icon and then hovering over it lets you see either side at the players own discretion
		x.view_tower()
	$Node3D.set_visible(true)
	for x: CollisionShape3D in choice_colliders:
		x.disabled = false
	card_available = true


func retrieve_card(i: int, _reply: Hero) -> void:
	$Node3D.set_visible(false)
	for x: CollisionShape3D in choice_colliders:
		x.disabled = true
	if card_available:
		var card: Card = cards[i].stats
		reply_player.add_card(card)
		#var item: ItemCard = item_card_scene.instantiate() as ItemCard
		#item.card = card
		#item.position = Vector3(1.683, 0, 0)
		#add_child(item)
	button_collider.disabled = false
	button_box.position = Vector3(0,0,0)
	$StaticBody3D/AudioStreamPlayer3D.play()
	reply_player = null


func _on_static_body_3d_button_interacted(_value: int, reply: Hero) -> void:
	reply_player = reply
	button_collider.disabled = true
	button_box.position = Vector3(0,0,-0.2)
	$StaticBody3D/AudioStreamPlayer3D.play()
	randomize_cards()
