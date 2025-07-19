class_name CardSelectionBox
extends Control

@export var icon: TextureRect
@export var tags: VBoxContainer
@export var cost_label: Label
@export var lifetime_label: Label
@export var unselected_style_box: StyleBoxFlat
@export var selected_style_box: StyleBoxFlat


func set_card(card: Card) -> void:
	icon.texture = card.icon
	cost_label.text = str(card.rarity + 1)
	lifetime_label.text = str(card.duration)
	for i: int in tags.get_child_count():
		tags.get_child(i).queue_free()
	for tag: Data.CardTags in card.tags:
		var tag_icon: TextureRect = icon.duplicate()
		if tag == Data.CardTags.DAMAGE:
			tag_icon.texture = load("res://Assets/Textures/damage_icon.png")
		if tag == Data.CardTags.UTILITY:
			tag_icon.texture = load("res://Assets/Textures/utility_icon.png")
		if tag == Data.CardTags.TARGETS_FLYING:
			tag_icon.modulate = Color.FIREBRICK
			tag_icon.texture = load("res://Assets/Textures/flight_icon.png")
		tags.add_child(tag_icon)


func set_key(slot: int) -> void:
	match(slot):
		0:
			$Label.text = parse_action_tag("#Equip 1#")
		1:
			$Label.text = parse_action_tag("#Equip 2#")
		2:
			$Label.text = parse_action_tag("#Equip 3#")
		3:
			$Label.text = parse_action_tag("#Equip 4#")
		4:
			$Label.text = parse_action_tag("#Equip 5#")
		5:
			$Label.text = parse_action_tag("#Equip 6#")
		6:
			$Label.text = parse_action_tag("#Equip 7#")
		7:
			$Label.text = parse_action_tag("#Equip 8#")
		8:
			$Label.text = parse_action_tag("#Equip 9#")
		9:
			$Label.text = parse_action_tag("#Equip 10#")


func parse_action_tag(text: String) -> String:
	var string_array: PackedStringArray = text.split("#")
	var output: Array[String] = []
	if string_array.size() > 1:
		for i: int in InputMap.action_get_events(string_array[1]).size():
			var event: InputEvent = InputMap.action_get_events(string_array[1])[i]
			if InputMap.action_get_events(string_array[1]).size() > 1:
				var last: bool = true if i == InputMap.action_get_events(string_array[1]).size() - 1 else false
				var first: bool = true if i == 0 else false
				if last:
					output.append(" or ")
				elif !first:
					output.append(", ")
			if event is InputEventKey:
				output.append("[img=top,50]%s[/img]" % KeyIconMap.keys[str(event.physical_keycode)])
			if event is InputEventMouseButton:
				output.append("[img=top,50]%s[/img]" % KeyIconMap.mouse_buttons[str(event.button_index)])
	string_array[1] = "".join(output)
	text = "".join(string_array)
	return text


func select() -> void:
	$PanelContainer.add_theme_stylebox_override("panel", selected_style_box)


func deselect() -> void:
	$PanelContainer.add_theme_stylebox_override("panel", unselected_style_box)
