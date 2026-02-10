class_name ShopStand extends Node3D

@export var cards: Array[CardInHand]
@export var choice_colliders: Array[CollisionShape3D]
@export var choice_buttons: Array[InteractButton]
@export var choice_sprites: Array[Sprite3D]
@export var item_card_scene: PackedScene
@export var blank_button: InteractButton
@export var blank_button_collider: CollisionShape3D
@export var blank_models: Array[CSGBox3D]

var price_dict: Dictionary = {
	Data.Rarity.UNCOMMON : 25,
	Data.Rarity.RARE : 40,
	Data.Rarity.EPIC : 60,
	Data.Rarity.LEGENDARY : 85,
}

var cards_generated: int = 0
var blanks_available: int = 5
var blank_cost: int = 20
var buy_blank_prompt: String = "PROMPT_BUY_BLANK"
var buy_card_prompt: String = "PROMPT_BUY_CARD"
var shops_generated: int = 0


func close() -> void:
	for x: CollisionShape3D in choice_colliders:
		x.disabled = true
	for x: Sprite3D in choice_sprites:
		x.visible = false
	for x: CSGBox3D in blank_models:
		x.visible = false
	blank_button_collider.disabled = true


func randomize_cards() -> void:
	blanks_available = 5
	var unlocked_classes: Array[HeroClass] = Data.save_data.get_unlocked_classes()
	var faction_choices: Array[Card.Faction]
	for hero: HeroClass in unlocked_classes:
		if !faction_choices.has(hero.faction):
			faction_choices.append(hero.faction)
	var random_faction: int = NoiseRandom.randi_in_range(shops_generated, 0, faction_choices.size() - 1)
	shops_generated += 1
	var cheap_cards: Array[Card] = []
	var medium_cards: Array[Card] = []
	var pricey_cards: Array[Card] = []
	for card: Card in Data.cards:
		if card.faction != random_faction:
			continue
		if card.rarity == Data.Rarity.UNCOMMON or card.rarity == Data.Rarity.RARE:
			cheap_cards.append(card)
		if card.rarity == Data.Rarity.RARE or card.rarity == Data.Rarity.EPIC:
			medium_cards.append(card)
		if card.rarity == Data.Rarity.EPIC or card.rarity == Data.Rarity.LEGENDARY:
			pricey_cards.append(card)
	
	var chosen_card: Card = null
	for x: int in 3:
		if cheap_cards.size() > 0:
			chosen_card = cheap_cards[NoiseRandom.randi_in_range(12 * cards_generated, 0, cheap_cards.size() - 1)]
		cards_generated += 1
		if chosen_card != null:
			cards[x].set_card(chosen_card)
			cards[x].view_tower()
			choice_buttons[x].press_cost = price_dict[chosen_card.rarity]
			choice_buttons[x].hover_text = tr(buy_card_prompt).format({Card_Name = tr(chosen_card.display_name), Card_Cost = str(price_dict[chosen_card.rarity])})
			if chosen_card.faction == Card.Faction.MAGE:
				Data.save_data.saw_mage_card_in_shop()
	for x: int in 2:
		if medium_cards.size() > 0:
			chosen_card = medium_cards[NoiseRandom.randi_in_range(9 * cards_generated, 0, medium_cards.size() - 1)]
		elif cheap_cards.size() > 0:
			chosen_card = cheap_cards[NoiseRandom.randi_in_range(9 * cards_generated, 0, cheap_cards.size() - 1)]
		cards_generated += 1
		if chosen_card != null:
			cards[x+3].set_card(chosen_card)
			cards[x+3].view_tower()
			choice_buttons[x+3].press_cost = price_dict[chosen_card.rarity]
			choice_buttons[x+3].hover_text = tr(buy_card_prompt).format({Card_Name = tr(chosen_card.display_name), Card_Cost = str(price_dict[chosen_card.rarity])})
			if chosen_card.faction == Card.Faction.MAGE:
				Data.save_data.saw_mage_card_in_shop()
	for x: int in 1:
		if pricey_cards.size() > 0:
			chosen_card = pricey_cards[NoiseRandom.randi_in_range(50 * cards_generated, 0, pricey_cards.size() - 1)]
		elif medium_cards.size() > 0:
			chosen_card = medium_cards[NoiseRandom.randi_in_range(50 * cards_generated, 0, medium_cards.size() - 1)]
		elif cheap_cards.size() > 0:
			chosen_card = cheap_cards[NoiseRandom.randi_in_range(50 * cards_generated, 0, cheap_cards.size() - 1)]
		cards_generated += 1
		if chosen_card != null:
			cards[x+5].set_card(chosen_card)
			cards[x+5].view_tower()
			choice_buttons[x+5].press_cost = price_dict[chosen_card.rarity]
			choice_buttons[x+5].hover_text = tr(buy_card_prompt).format({Card_Name = tr(chosen_card.display_name), Card_Cost = str(price_dict[chosen_card.rarity])})
			if chosen_card.faction == Card.Faction.MAGE:
				Data.save_data.saw_mage_card_in_shop()
	for x: CollisionShape3D in choice_colliders:
		x.set_deferred("disabled", false)
	for x: Sprite3D in choice_sprites:
		x.visible = true
	for x: CSGBox3D in blank_models:
		x.visible = true
	blank_button_collider.set_deferred("disabled", false)
	blank_button.hover_text = tr(buy_blank_prompt).format({Blank_Cost = str(blank_cost)})


func retrieve_card(i: int, callback: Hero) -> void:
	if callback.currency >= price_dict[cards[i].stats.rarity]:
		choice_colliders[i].disabled = true
		choice_sprites[i].set_visible(false)
		var card: Card = cards[i].stats
		if card.faction == Card.Faction.ENGINEER:
			Data.save_data.bought_engineer_card()
		if card.faction == Card.Faction.MAGE:
			Data.save_data.bought_mage_card()
		callback.currency -= price_dict[cards[i].stats.rarity]
		callback.add_card(card)


func retrieve_blank(_i: int, callback: Hero) -> void:
	if callback.currency >= blank_cost:
		blank_models[5 - blanks_available].visible = false
		blanks_available -= 1
		callback.currency -= blank_cost
		callback.blank_cassettes += 1
		if blanks_available == 0:
			blank_button_collider.disabled = true
