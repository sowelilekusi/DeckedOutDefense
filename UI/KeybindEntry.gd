class_name KeybindEntry extends HBoxContainer

signal bind_button_pressed(button: Button)

var action_string: String
var event_buttons: Array[BindButton]


func to_array() -> Array:
	var binding_list: Array = []
	binding_list.append([action_string])
	for button: BindButton in event_buttons:
		var binding: Array = []
		if button.trigger_event is InputEventKey:
			binding.append("InputEventKey")
			binding.append(button.trigger_event.physical_keycode)
		if button.trigger_event is InputEventMouseButton:
			binding.append("InputEventMouseButton")
			binding.append(button.trigger_event.button_index)
		if button.trigger_event is InputEventJoypadButton:
			binding.append("InputEventJoypadButton")
			binding.append(button.trigger_event.button_index)
		binding_list.append(binding)
	return binding_list


func populate_from_array(binding_list: Array) -> void:
	action_string = binding_list[0][0]
	for i: int in binding_list.size() - 1:
		if i == 0:
			continue
		for binding: Array in binding_list[i]:
			add_bind_button(KeymapData.event_from_array(binding))


func set_action_name(action_name: String) -> void:
	action_string = action_name
	$ActionName.text = action_name


func button_pressed(button: Button) -> void:
	bind_button_pressed.emit(button)


func set_button_bind(event: InputEvent, button: BindButton) -> void:
	button.trigger_event = event
	button.text = ""
	if event is InputEventKey:
		if KeyIconMap.keys.has(str(event.physical_keycode)):
			button.icon = load(KeyIconMap.keys[str(event.physical_keycode)])
	elif event is InputEventMouseButton:
		if event.button_index == 4:
			button.icon = load(KeyIconMap.mouse_buttons[str(event.button_index)])
		elif event.button_index == 5:
			button.icon = load(KeyIconMap.mouse_buttons[str(event.button_index)])
		elif event.button_index == 6:
			button.text = "Mouse Wheel Left"
		elif event.button_index == 7:
			button.text = "Mouse Wheel Right"
		elif event.button_index == 8:
			button.text = "Mouse Button 4"
		elif event.button_index == 9:
			button.text = "Mouse Button 5"
		elif KeyIconMap.mouse_buttons.has(str(event.button_index)):
			button.icon = load(KeyIconMap.mouse_buttons[str(event.button_index)])
	elif event is InputEventJoypadButton:
		if Input.get_joy_name(event.device) == "Xbox 360 Controller":
			button.icon = load(KeyIconMap.xbox_360_keys[str(event.button_index)])
		elif Input.get_joy_name(event.device) == "Xbox Series Controller":
			button.icon = load(KeyIconMap.xbox_series_keys[str(event.button_index)])
		elif Input.get_joy_name(event.device).contains("Playstation"):
			button.icon = load(KeyIconMap.playstation_keys[str(event.button_index)])


func set_cross_button_visibility(button: Button, visibility: bool) -> void:
	button.visible = visibility


func add_bind_button(event: InputEvent) -> BindButton:
	#Create binding button
	var new_button: BindButton = BindButton.new()
	new_button.mouse_filter = Control.MOUSE_FILTER_PASS
	new_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	new_button.custom_minimum_size = Vector2(75.0, 75.0)
	new_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_button.expand_icon = true
	new_button.pressed.connect(button_pressed.bind(new_button))
	if event:
		set_button_bind(event, new_button)
	event_buttons.append(new_button)
	
	#Create delete button
	var cross_button: Button = Button.new()
	cross_button.icon = load("res://Assets/Textures/flair_disabled_cross.png")
	cross_button.visible = false
	cross_button.mouse_filter = Control.MOUSE_FILTER_PASS
	cross_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cross_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cross_button.expand_icon = true
	cross_button.pressed.connect(remove_bind_button.bind(new_button))
	
	#Create vbox to hold buttons
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_STOP
	vbox.custom_minimum_size = Vector2(100.0, 100.0)
	vbox.mouse_entered.connect(set_cross_button_visibility.bind(cross_button, true))
	vbox.mouse_exited.connect(set_cross_button_visibility.bind(cross_button, false))
	
	#Add buttons to vbox and add vbox to button grid
	vbox.add_child(new_button)
	vbox.add_child(cross_button)
	$Buttons.add_child(vbox)
	$Buttons.move_child(vbox, $Buttons.get_child_count() - 2)
	
	return new_button


func remove_bind_button(button: BindButton) -> void:
	event_buttons.erase(button)
	button.get_parent().queue_free()


func _on_add_bind_button_pressed() -> void:
	add_bind_button(null).pressed.emit()
