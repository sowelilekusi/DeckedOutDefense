extends Control
class_name HeroSelector

signal hero_selected(hero_class)

@export var hero_card_scene: PackedScene
@export var hbox: HBoxContainer


func _ready() -> void:
	for hero in Data.characters:
		var card = hero_card_scene.instantiate()
		card.set_hero(hero)
		card.pressed.connect(func(x): hero_selected.emit(Data.characters.find(x)))
		hbox.add_child(card)
