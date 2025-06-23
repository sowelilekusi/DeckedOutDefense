class_name CardPrinter extends StaticBody3D

@export var button_collider: CollisionShape3D

#TODO: use faction enum
var base_faction: int = 1
var cards_generated: int = 0
var reply_player: Hero
var spawned_cards: Array[CardItem] = []


func get_faction_cards(faction: Card.Faction) -> Array[Card]:
	var valid_cards: Array[Card] = []
	for card: Card in Data.cards:
		if card.faction == faction:
			valid_cards.append(card)
	return valid_cards


func generate_rarity() -> int:
	var weight_total: int = 0
	for rarity: String in Data.Rarity:
		weight_total += Data.rarity_weights[rarity]
	
	var generated_rarity: int = NoiseRandom.randi_in_range(4 * cards_generated, 0, weight_total)
	cards_generated += 1
	var decided_rarity: int = 0
	
	for rarity: String in Data.Rarity:
		weight_total -= Data.rarity_weights[rarity]
		if generated_rarity >= weight_total:
			decided_rarity = Data.Rarity[rarity]
			break
	return decided_rarity


func randomize_cards(faction: Card.Faction) -> void:
	#TODO: no magic numbers, asshole! 3 = cards to spawn
	var pos_x: float = 0.0
	for x: int in 3:
		var decided_rarity: int = generate_rarity()
		var card_choices: Array[Card] = get_faction_cards(faction)
		var card_array: Array = []
		var cards_chosen: bool = false
		while !cards_chosen:
			for card: Card in card_choices:
				if card.rarity == decided_rarity:
					card_array.append(card)
					cards_chosen = true
			if decided_rarity < 0:
				card_array.append(Data.cards[0])
				cards_chosen = true
			decided_rarity -= 1
		var card: Card
		if card_array.size() > 0:
			card = card_array[NoiseRandom.randi_in_range(132 * cards_generated, 0, card_array.size() - 1)]
			cards_generated += 1
			card_array.erase(card)
		var item: CardItem = reply_player.hero_class.card_item.instantiate() as CardItem
		item.set_card(card)
		item.position = Vector3(pos_x, 2, 0)
		pos_x *= -1
		if pos_x >= 0:
			pos_x += 1.25
		item.pressed.connect(card_picked_up)
		spawned_cards.append(item)
		add_child(item)


func card_picked_up(card_item: CardItem) -> void:
	reply_player.add_card(card_item.card)
	reply_player = null
	for spawned_card: CardItem in spawned_cards:
		spawned_card.queue_free()
	spawned_cards = []
	button_collider.disabled = false
	$StaticBody3D/AudioStreamPlayer3D.play()


func _on_static_body_3d_button_interacted(_value: int, reply: Hero) -> void:
	reply_player = reply
	button_collider.disabled = true
	$StaticBody3D/AudioStreamPlayer3D.play()
	randomize_cards(reply.hero_class.faction)
