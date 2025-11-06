class_name RemixTable
extends StaticBody3D

@export var remix_menu_scene: PackedScene
@export var button: InteractButton

var reply_player: Hero

func _ready() -> void:
	button.hover_text = tr("PROMPT_REMIX_INTERACT")


func _on_static_body_3d_button_interacted(_value: int, callback: Hero) -> void:
	if callback.hand.size >= 1:
		reply_player = callback
		var menu: TrackEditor = remix_menu_scene.instantiate() as TrackEditor
		var card_array: Array[Card] = []
		for card: Card in callback.hand.contents:
			card_array.append(card)
		menu.hero = reply_player
		menu.set_money(reply_player.currency)
		menu.populate_feature_slots()
		menu.add_option(card_array)
		menu.cards_remixed.connect(output)
		reply_player.pause()
		reply_player.hud.add_child(menu)


func output(cards_to_remove: Array[Card], cards_to_add: Array[Card], amount_spent: int) -> void:
	for card: Card in cards_to_remove:
		reply_player.hand.contents.erase(card)
		reply_player.hud.hot_wheel.update_cassettes(reply_player.get_wheel_cards())
	for card: Card in cards_to_add:
		reply_player.add_card(card)
	reply_player.currency -= amount_spent
	reply_player.unpause()
