class_name Inventory
extends Node

signal item_added(item: Item)
signal item_removed(item: Item)

@export var max_size: int = 0
var contents: Dictionary = {}
var size: int :
	get:
		var x: int = 0
		for key: Item in contents:
			x += contents[key]
		return x
	set(_value):
		return


func add(item: Item) -> bool:
	if item != null and max_size == 0 or size < max_size:
		if contents.has(item):
			contents[item] += 1
		else:
			contents[item] = 1
		item_added.emit(item)
		#networked_add.rpc(Data.cards.find(item))
		return true
	return false


func remove_at(index: int) -> Item:
	var item: Item = contents.keys()[index]
	contents[item] -= 1
	if contents[item] == 0:
		contents.erase(item)
	item_removed.emit(item)
	#networked_remove_at.rpc(index)
	return item


@rpc("reliable", "any_peer")
func networked_add(value: int) -> void:
	var item: Item = Data.cards[value]
	if contents.has(item):
		contents[item] += 1
	else:
		contents[item] = 1
	item_added.emit(item)


@rpc("reliable", "any_peer")
func networked_remove_at(value: int) -> void:
	var item: Item = contents.keys()[value]
	contents[item] -= 1
	if contents[item] == 0:
		contents.erase(item)
	item_removed.emit(item)
