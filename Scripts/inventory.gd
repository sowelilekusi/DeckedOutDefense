extends Node
class_name Inventory

signal item_added(item)
signal item_removed(item)

@export var max_size := 0
var contents = {}
var size : int :
	get:
		var x = 0
		for key in contents:
			x += contents[key]
		return x
	set(_value):
		return


func add(item : Item) -> bool:
	if item != null and max_size == 0 or size < max_size:
		if contents.has(item):
			contents[item] += 1
		else:
			contents[item] = 1
		item_added.emit(item)
		networked_add.rpc(Data.cards.find(item))
		return true
	return false


func remove_at(index : int) -> Item:
	var item = contents.keys()[index]
	contents[item] -= 1
	if contents[item] == 0:
		contents.erase(item)
	item_removed.emit(item)
	networked_remove_at.rpc(index)
	return item


@rpc("reliable", "any_peer")
func networked_add(value):
	var item = Data.cards[value]
	if contents.has(item):
		contents[item] += 1
	else:
		contents[item] = 0
	item_added.emit(item)


@rpc("reliable", "any_peer")
func networked_remove_at(value):
	var item = contents.keys[value]
	contents[item] -= 1
	if contents[item] == 0:
		contents.erase(item)
	item_removed.emit(item)
