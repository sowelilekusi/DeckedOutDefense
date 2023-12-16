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
		card.button_mouse_entered.connect(_on_button_mouse_entered)
		hbox.add_child(card)


func _on_button_mouse_entered():
	$AudioStreamPlayer.play()
