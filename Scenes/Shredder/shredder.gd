class_name Shredder extends StaticBody3D


func _on_interact_button_button_interacted(_value: int, callback: Hero) -> void:
	var card: Card = callback.inventory.remove_at(callback.inventory_selected_index) as Card
	callback.currency += 5 * (card.rarity + 1)
