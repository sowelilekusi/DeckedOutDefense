class_name ShopStand extends Node3D

@export var cards: Array[CardInHand]
@export var choice_colliders: Array[CollisionShape3D]
@export var choice_buttons: Array[InteractButton]
@export var choice_sprites: Array[Sprite3D]
@export var item_card_scene: PackedScene

var price_dict: Dictionary = {
	Data.Rarity.UNCOMMON : 25,
	Data.Rarity.RARE : 40,
	Data.Rarity.EPIC : 60,
	Data.Rarity.LEGENDARY : 85,
}

var cards_generated: int = 0


func close() -> void:
	for x: CollisionShape3D in choice_colliders:
		x.disabled = true
	for x: Sprite3D in choice_sprites:
		x.set_visible(false)


func randomize_cards() -> void:
	var cheap_cards: Array[Card] = []
	var medium_cards: Array[Card] = []
	var pricey_cards: Array[Card] = []
	for card: Card in Data.cards:
		if card.rarity == Data.Rarity.UNCOMMON or card.rarity == Data.Rarity.RARE:
			cheap_cards.append(card)
		if card.rarity == Data.Rarity.RARE or card.rarity == Data.Rarity.EPIC:
			medium_cards.append(card)
		if card.rarity == Data.Rarity.EPIC or card.rarity == Data.Rarity.LEGENDARY:
			pricey_cards.append(card)
	
	for x: int in 3:
		var chosen_card: Card = cheap_cards[Game.randi_in_range(12 * cards_generated, 0, cheap_cards.size() - 1)]
		cards_generated += 1
		cards[x].set_card(chosen_card)
		cards[x].view_tower()
		choice_buttons[x].press_cost = price_dict[chosen_card.rarity]
		choice_buttons[x].hover_text = "Spend $" + str(choice_buttons[x].press_cost) + " to acquire " + chosen_card.display_name + "?"
	for x: int in 2:
		var chosen_card: Card = medium_cards[Game.randi_in_range(9 * cards_generated, 0, medium_cards.size() - 1)]
		cards_generated += 1
		cards[x+3].set_card(chosen_card)
		cards[x+3].view_tower()
		choice_buttons[x+3].press_cost = price_dict[chosen_card.rarity]
		choice_buttons[x+3].hover_text = "Spend $" + str(choice_buttons[x+3].press_cost) + " to acquire " + chosen_card.display_name + "?"
	for x: int in 1:
		var chosen_card: Card = pricey_cards[Game.randi_in_range(50 * cards_generated, 0, pricey_cards.size() - 1)]
		cards_generated += 1
		cards[x+5].set_card(chosen_card)
		cards[x+5].view_tower()
		choice_buttons[x+5].press_cost = price_dict[chosen_card.rarity]
		choice_buttons[x+5].hover_text = "Spend $" + str(choice_buttons[x+5].press_cost) + " to acquire " + chosen_card.display_name + "?"
	for x: CollisionShape3D in choice_colliders:
		x.set_deferred("disabled", false)
	for x: Sprite3D in choice_sprites:
		x.set_visible(true)


func retrieve_card(i: int, callback: Hero) -> void:
	#close()
	choice_colliders[i].disabled = true
	choice_sprites[i].set_visible(false)
	var card: Card = cards[i].stats
	callback.add_card(card)
	#var item: ItemCard = item_card_scene.instantiate() as ItemCard
	#item.card = card
	#item.position = Vector3(2.128, 0, 0)
	#add_child(item)
	#button_collider.disabled = false
	#button_box.position = Vector3(0,0,0)
