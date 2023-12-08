extends PanelContainer

signal pressed(hero_class)

var hero_class: HeroClass


func set_hero(hero: HeroClass):
	hero_class = hero
	$VBoxContainer/Label.text = hero.hero_name
	$VBoxContainer/TextureRect.texture = hero.texture


func _on_button_pressed() -> void:
	pressed.emit(hero_class)
