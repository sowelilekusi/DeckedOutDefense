class_name CardPrinter extends StaticBody3D

@export var button: InteractButton
@export var button_collider: CollisionShape3D
@export var card_selection_menu: PackedScene

#TODO: use faction enum
var base_faction: int = 1
var cards_generated: int = 0
var reply_player: Hero
var spawned_cards: Array[CardItem] = []


func _ready() -> void:
	button.hover_text = tr("PROMPT_RADIO_INTERACT")


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


func find_cards(faction: Card.Faction, rarity: Data.Rarity, allowed_cards: Array[Card]) -> void:
	var decided_rarity: int = rarity
	if !decided_rarity:
		decided_rarity = generate_rarity()
	var card_choices: Array[Card] = allowed_cards
	if !card_choices:
		card_choices = get_faction_cards(faction)
	var cards: Array[Card] = []
	var valid_cards_found: bool = false
	var testing_rarity: int = decided_rarity
	while !valid_cards_found:
		for card: Card in card_choices:
			if card.rarity == testing_rarity:
				cards.append(card)
		if cards.size() != 0:
			valid_cards_found = true
		testing_rarity -= 1
		if testing_rarity < 0:
			testing_rarity = 4
		if testing_rarity == decided_rarity:
			print("This character doesn't have any cards!")
			return
	var menu: ChooseCardScreen = card_selection_menu.instantiate() as ChooseCardScreen
	menu.add_cards(cards)
	menu.card_chosen.connect(output_card)
	reply_player.pause()
	reply_player.hud.add_child(menu)


func card_picked_up(card_item: CardItem) -> void:
	reply_player.add_card(card_item.card)
	reply_player = null
	for spawned_card: CardItem in spawned_cards:
		spawned_card.queue_free()
	spawned_cards = []
	button_collider.disabled = false
	$StaticBody3D/AudioStreamPlayer3D.play()


func output_card(card: Card) -> void:
	reply_player.add_card(card)
	reply_player.unpause()
	reply_player = null
	button_collider.disabled = false
	$StaticBody3D/AudioStreamPlayer3D.play()


func _on_static_body_3d_button_interacted(_value: int, reply: Hero) -> void:
	reply_player = reply
	if reply.blank_cassettes >= 1:
		reply.blank_cassettes -= 1
	else:
		return
	button_collider.disabled = true
	$StaticBody3D/AudioStreamPlayer3D.play()
	find_cards(reply.hero_class.faction, reply.game_manager.level_specs.waves[reply.game_manager.wave].station, reply.game_manager.level_specs.allowed_cards)
