class_name RemixMenu
extends Control

signal cards_remixed(cards_consumed: Array[Card], cards_created: Array[Card])

@export var card_ui_one: CardDescriptionUI
@export var card_ui_two: CardDescriptionUI
@export var option_button_one: OptionButton
@export var option_button_two: OptionButton

var cards: Array[Card]

var card_one: Card
var card_two: Card

var temp_card_one: Card
var temp_card_two: Card


func add_option(card_options: Array[Card]) -> void:
	cards = card_options
	for card: Card in cards:
		option_button_one.add_item(tr(card.display_name))
		option_button_two.add_item(tr(card.display_name))
	option_button_one.select(0)
	set_card_one(0)
	option_button_two.select(1)
	set_card_two(1)


func set_cards(first_card: Card, second_card: Card) -> void:
	card_one = first_card
	card_two = second_card


func set_card_one(option: int) -> void:
	card_one = cards[option]
	card_ui_one.set_card(card_one, true)


func set_card_two(option: int) -> void:
	card_two = cards[option]
	card_ui_two.set_card(card_two, true)


func remix() -> void:
	temp_card_one = card_one.duplicate(true)
	temp_card_one.tower_stats = temp_card_one.tower_stats.duplicate_deep()
	temp_card_one.weapon_stats = temp_card_one.weapon_stats.duplicate_deep()
	for feature: Feature in card_two.tower_stats.features:
		temp_card_one.tower_stats.features.append(feature)
	for feature: Feature in card_two.weapon_stats.features:
		temp_card_one.weapon_stats.features.append(feature)
	
	temp_card_two = card_two.duplicate(true)
	temp_card_two.tower_stats = temp_card_two.tower_stats.duplicate_deep()
	temp_card_two.weapon_stats = temp_card_two.weapon_stats.duplicate_deep()
	for feature: Feature in card_one.tower_stats.features:
		temp_card_two.tower_stats.features.append(feature)
	for feature: Feature in card_one.weapon_stats.features:
		temp_card_two.weapon_stats.features.append(feature)
	
	card_ui_one.set_card(temp_card_one, true)
	card_ui_two.set_card(temp_card_two, true)


func _on_button_2_pressed() -> void:
	var card_array_one: Array[Card]
	var card_array_two: Array[Card]
	card_array_one.append(card_one)
	card_array_one.append(card_two)
	card_array_two.append(temp_card_one)
	card_array_two.append(temp_card_two)
	cards_remixed.emit(card_array_one, card_array_two)
	queue_free()
