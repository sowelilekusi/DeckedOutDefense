class_name HotWheel
extends HBoxContainer

@export var buttons: Array[Button]


func update_cassettes(cassettes: Array[Card]) -> void:
	var entry_count: int = cassettes.size()
	buttons[0].visible = true
	buttons[1].visible = true
	buttons[2].visible = true
	buttons[3].visible = true
	buttons[4].visible = true
	if entry_count < 1:
		buttons[0].visible = false
		buttons[1].visible = false
		buttons[2].visible = false
		buttons[3].visible = false
		buttons[4].visible = false
	elif entry_count < 2:
		buttons[0].visible = false
		buttons[1].visible = false
		buttons[3].visible = false
		buttons[4].visible = false
	elif entry_count < 4:
		buttons[0].visible = false
		buttons[4].visible = false
	if entry_count >= 1:
		buttons[2].icon = cassettes[0].icon
	if entry_count >= 2:
		buttons[1].icon = cassettes[1].icon
		buttons[3].icon = cassettes[1].icon
	if entry_count >= 3:
		buttons[3].icon = cassettes[2].icon
	if entry_count >= 4:
		buttons[0].icon = cassettes[3].icon
		buttons[4].icon = cassettes[3].icon
	if entry_count >= 5:
		buttons[4].icon = cassettes[4].icon
