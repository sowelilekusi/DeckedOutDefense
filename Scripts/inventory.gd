extends Node
class_name Inventory

signal item_added(item)
signal item_removed(item)

@export var max_size := 0
var contents : Array[Card] = []
var selected_index := 0
var selected_item : Card :
	get:
		return contents[selected_index] if contents.size() > 0 else null
	set(_value):
		return


func add(card : Card) -> bool:
	if card != null and contents.size() < max_size or max_size == 0:
		contents.append(card)
		item_added.emit(card)
		networked_add.rpc(Data.cards.find(card))
		return true
	return false


func remove_at(index : int) -> Card:
	if contents.size() <= 0:
		return null
	var card = contents[index]
	contents.remove_at(index)
	if selected_index >= contents.size() and selected_index > 0:
		selected_index -= 1
	item_removed.emit(card)
	networked_remove_at.rpc(index)
	return card


func remove() -> Card:
	return remove_at(selected_index)


func increment_selected():
	if contents.size() > 0:
		selected_index += 1
		if selected_index >= contents.size():
			selected_index = 0
	networked_set_selected.rpc(selected_index)


func decrement_selected():
	if contents.size() > 0:
		selected_index -= 1
		if selected_index < 0:
			selected_index = contents.size() - 1
	networked_set_selected.rpc(selected_index)


@rpc("reliable", "any_peer")
func networked_add(value):
	contents.append(Data.cards[value])
	item_added.emit(Data.cards[value])


@rpc("reliable", "any_peer")
func networked_remove_at(value):
	var item = contents[value]
	contents.remove_at(value)
	item_removed.emit(item)


@rpc("reliable", "any_peer")
func networked_set_selected(value):
	selected_index = value
