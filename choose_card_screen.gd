class_name ChooseCardScreen extends Control

signal card_chosen(card: Card)

@export var choice_buttons: VBoxContainer
@export var card_name_label: Label
@export var card_description_label: RichTextLabel

var choices: Array[Card] = []
var chosen_card: Card = null
var side_a: bool = true


func add_cards(cards: Array[Card]) -> void:
	var x: int = 0
	for card: Card in cards:
		var button: Button = Button.new()
		button.text = tr(card.display_name)
		button.pressed.connect(choose_card.bind(x))
		choices.append(card)
		choice_buttons.add_child(button)
		x += 1
	choose_card(0)


func choose_card(choice: int) -> void:
	chosen_card = choices[choice]
	card_name_label.text = tr(chosen_card.display_name)
	choose_side(side_a)


func choose_side(side_a_chosen: bool) -> void:
	side_a = side_a_chosen
	card_description_label.text = tr(chosen_card.tower_stats.text) if side_a else tr(chosen_card.weapon_stats.text)


func _on_confirm_button_pressed() -> void:
	card_chosen.emit(chosen_card)
	queue_free()
