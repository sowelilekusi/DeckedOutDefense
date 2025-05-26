extends HBoxContainer
class_name KeybindEntry

signal primary_bind_pressed()
signal secondary_bind_pressed()

var action_string: String


func set_action_name(action_name: String) -> void:
	action_string = action_name
	$ActionName.text = action_name


func set_primary_bind(event: InputEvent) -> void:
	if event is InputEventKey:
		if KeyIconMap.keys.has(str(event.keycode)):
			$Buttons/PrimaryBind.icon = load(KeyIconMap.keys[str(event.keycode)])
	elif event is InputEventMouseButton:
		if event.button_index == 4:
			$Buttons/PrimaryBind.text = "Mouse Wheel Up"
		elif event.button_index == 5:
			$Buttons/PrimaryBind.text = "Mouse Wheel Down"
		elif event.button_index == 6:
			$Buttons/PrimaryBind.text = "Mouse Wheel Left"
		elif event.button_index == 7:
			$Buttons/PrimaryBind.text = "Mouse Wheel Right"
		elif event.button_index == 8:
			$Buttons/PrimaryBind.text = "Mouse Button 4"
		elif event.button_index == 9:
			$Buttons/PrimaryBind.text = "Mouse Button 5"
		elif KeyIconMap.mouse_buttons.has(str(event.button_index)):
			$Buttons/PrimaryBind.icon = load(KeyIconMap.mouse_buttons[str(event.button_index)])


func set_secondary_bind(event: InputEvent) -> void:
	if event is InputEventKey:
		if KeyIconMap.keys.has(str(event.keycode)):
			$Buttons/SecondaryBind.icon = load(KeyIconMap.keys[str(event.keycode)])
	elif event is InputEventMouseButton:
		if event.button_index == 4:
			$Buttons/PrimaryBind.text = "Mouse Wheel Up"
		elif event.button_index == 5:
			$Buttons/PrimaryBind.text = "Mouse Wheel Down"
		elif event.button_index == 6:
			$Buttons/PrimaryBind.text = "Mouse Wheel Left"
		elif event.button_index == 7:
			$Buttons/PrimaryBind.text = "Mouse Wheel Right"
		elif event.button_index == 8:
			$Buttons/PrimaryBind.text = "Mouse Button 4"
		elif event.button_index == 9:
			$Buttons/PrimaryBind.text = "Mouse Button 5"
		elif KeyIconMap.mouse_buttons.has(str(event.button_index)):
			$Buttons/PrimaryBind.icon = load(KeyIconMap.mouse_buttons[str(event.button_index)])


func _on_primary_bind_pressed() -> void:
	primary_bind_pressed.emit()


func _on_secondary_bind_pressed() -> void:
	secondary_bind_pressed.emit()
