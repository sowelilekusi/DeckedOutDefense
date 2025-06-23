class_name ScoreboardEntry
extends HBoxContainer

var display_name: String
var character: int
var ready_state: bool


func set_display_name(_old_name: String, new_name: String) -> void:
	display_name = new_name
	$DisplayName.text = new_name
func get_display_name() -> String:
	return display_name

func set_character(_old_class: int, new_class: int) -> void:
	character = new_class
	$CharacterName.text = Data.characters[new_class].hero_name
func get_character() -> int:
	return character

func set_ready_state(state: bool) -> void:
	ready_state = state
	if state:
		$TextureRect.texture.region = Rect2(32, 0, 32, 32)
	else:
		$TextureRect.texture.region = Rect2(0, 0, 32, 32)
func get_ready_state() -> bool:
	return ready_state
