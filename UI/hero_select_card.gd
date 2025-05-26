extends PanelContainer

signal pressed(hero_class: int)
signal button_mouse_entered()

var hero_class: HeroClass


func set_hero(hero: HeroClass) -> void:
	hero_class = hero
	$VBoxContainer/Label.text = hero.hero_name
	$VBoxContainer/TextureRect.texture = hero.texture


func _on_button_pressed() -> void:
	pressed.emit(Data.characters.find(hero_class))


func _on_button_mouse_entered() -> void:
	button_mouse_entered.emit()
