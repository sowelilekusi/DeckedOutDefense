extends PanelContainer

signal pressed(hero_class)
signal button_mouse_entered()

var hero_class: HeroClass


func set_hero(hero: HeroClass):
	hero_class = hero
	$VBoxContainer/Label.text = hero.hero_name
	$VBoxContainer/TextureRect.texture = hero.texture


func _on_button_pressed() -> void:
	pressed.emit(hero_class)


func _on_button_mouse_entered() -> void:
	button_mouse_entered.emit()
