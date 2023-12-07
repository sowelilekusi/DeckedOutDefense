extends Node
class_name Inventory

signal item_added(item)
signal item_removed(item)

@export var max_size := 0
@export var contents : Array[Item] = []
var selected_index := 0
var selected_item : Item :
	get:
		return contents[selected_index] if contents.size() > 0 else null
	set(_value):
		return


func add(item : Item) -> bool:
	if item != null and contents.size() < max_size or max_size == 0:
		contents.append(item)
		item_added.emit(item)
		networked_add.rpc(Data.cards.find(item))
		return true
	return false


func remove_at(index : int) -> Item:
	if contents.size() <= 0:
		return null
	var item = contents[index]
	contents.remove_at(index)
	if selected_index >= contents.size() and selected_index > 0:
		selected_index -= 1
	item_removed.emit(item)
	networked_remove_at.rpc(index)
	return item


func remove() -> Item:
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
