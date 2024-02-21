class_name LoadoutEditor extends Panel

signal character_selected(character: int)


func _ready() -> void:
	for i: int in Data.characters.size():
		var button: Button = Button.new()
		button.text = Data.characters[i].hero_name
		button.pressed.connect(set_character.bind(i))
		$HBoxContainer.add_child(button)


func set_character(i: int) -> void:
	character_selected.emit(i)
