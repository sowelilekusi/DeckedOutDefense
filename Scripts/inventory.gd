class_name Inventory
extends Node

signal item_added(item: Item)
signal item_removed(item: Item)

@export var max_size: int = 0
var shuffle_count: int = 0
var contents: Array[Item] = []
var size: int :
	set(_value):
		return
	get:
		return contents.size()


func add(item: Item) -> bool:
	if item != null and max_size == 0 or size < max_size:
		contents.append(item)
		item_added.emit(item)
		#networked_add.rpc(Data.cards.find(item))
		return true
	return false


func item_at(index: int) -> Item:
	#if size == 0:
		#return null
	var item: Item = contents[index]
	return item


func remove_at(index: int) -> Item:
	var item: Item = contents.pop_at(index)
	item_removed.emit(item)
	return item


func shuffle() -> void:
	var new_contents: Array[Item] = []
	for x: int in contents.size():
		new_contents.append(contents.pop_at(NoiseRandom.randi_in_range(shuffle_count * 9, 0, contents.size() - 1)))
	contents = new_contents


#@rpc("reliable", "any_peer")
#func networked_add(value: int) -> void:
	#var item: Item = Data.cards[value]
	#if contents.has(item):
		#contents[item] += 1
	#else:
		#contents[item] = 1
	#item_added.emit(item)
#
#
#@rpc("reliable", "any_peer")
#func networked_remove_at(value: int) -> void:
	#var item: Item = contents.keys()[value]
	#contents[item] -= 1
	#if contents[item] == 0:
		#contents.erase(item)
	#item_removed.emit(item)
