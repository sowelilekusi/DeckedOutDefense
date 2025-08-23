class_name RemixTable
extends StaticBody3D

@export var remix_menu_scene: PackedScene

var reply_player: Hero


func _on_static_body_3d_button_interacted(value: int, callback: Hero) -> void:
	if callback.hand.size >= 2:
		reply_player = callback
		var menu: RemixMenu = remix_menu_scene.instantiate() as RemixMenu
		var card_array: Array[Card] = []
		for card: Card in callback.hand.contents:
			card_array.append(card)
		menu.add_option(card_array)
		menu.cards_remixed.connect(output)
		reply_player.pause()
		reply_player.hud.add_child(menu)


func output(cards_to_remove: Array[Card], cards_to_add: Array[Card]) -> void:
	for card: Card in cards_to_remove:
		reply_player.hand.contents.erase(card)
	for card: Card in cards_to_add:
		reply_player.add_card(card)
	reply_player.unpause()
