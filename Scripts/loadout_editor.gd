extends Panel
class_name LoadoutEditor

signal character_selected(character)

func _ready() -> void:
	for i in Data.characters.size():
		var button = Button.new()
		button.text = Data.characters[i].hero_name
		button.pressed.connect(set_character.bind(i))
		$HBoxContainer.add_child(button)


func set_character(i: int):
	character_selected.emit(i)
