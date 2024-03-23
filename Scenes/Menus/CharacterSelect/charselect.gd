class_name HeroSelector extends Control

signal hero_selected(hero_class: int)

@export var hero_card_scene: PackedScene
@export var hbox: HBoxContainer


func _ready() -> void:
	for hero: HeroClass in Data.characters:
		var card: Control = hero_card_scene.instantiate()
		card.set_hero(hero)
		card.pressed.connect(func(x: int) -> void: hero_selected.emit(x))
		card.button_mouse_entered.connect(_on_button_mouse_entered)
		hbox.add_child(card)


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()
