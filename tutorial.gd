extends Node3D

var move_hint_onscreen: bool = true


func _on_interact_button_button_interacted(value: int, callback: Hero) -> void:
	$SpawnRoom/door.queue_free()
	fade_move_hint()


func _ready() -> void:
	$HBoxContainer/VBoxContainer/RichTextLabel.text = parse_action_tag($HBoxContainer/VBoxContainer/RichTextLabel.text)
	$HBoxContainer/VBoxContainer/RichTextLabel2.text = parse_action_tag($HBoxContainer/VBoxContainer/RichTextLabel2.text)


func parse_action_tag(text: String) -> String:
	var string_array: PackedStringArray = text.split("#")
	var output: Array[String] = []
	if string_array.size() > 1:
		for x: int in range(1, string_array.size() - 1):
			for i: int in InputMap.action_get_events(string_array[x]).size():
				var event: InputEvent = InputMap.action_get_events(string_array[x])[i]
				if InputMap.action_get_events(string_array[x]).size() > 1:
					var last: bool = true if i == InputMap.action_get_events(string_array[x]).size() - 1 else false
					var first: bool = true if i == 0 else false
					if last:
						output.append(" or ")
					elif !first:
						output.append(", ")
				if event is InputEventKey:
					output.append("[img=top,50]%s[/img]" % KeyIconMap.keys[str(event.physical_keycode)])
				if event is InputEventMouseButton:
					output.append("[img=top,50]%s[/img]" % KeyIconMap.mouse_buttons[str(event.button_index)])
	#string_array[string_array.size() - 1] = "".join(output)
	text = "".join(output)
	return text


func fade_move_hint() -> void:
	if move_hint_onscreen:
		pass
		var tween: Tween = create_tween()
		tween.tween_property($HBoxContainer, "modulate", Color(1.0, 1.0, 1.0, 0.0), 2.0)
