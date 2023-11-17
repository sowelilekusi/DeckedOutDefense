extends VBoxContainer

var keybind_popup = load("res://Scenes/UI/keybind_popup.tscn")
var keybind_boxes = []
var keybind_buttons = {}
var key_event
var selected_button
var selected_button_button
var listening_for_key := false


func _ready() -> void:
	for index in Data.keymaps.size():
		var map = Data.keymaps[index]
		var button = Button.new()
		button.text = map.title
		button.pressed.connect(set_keymap.bind(index))
		$HBoxContainer.add_child(button)
	load_keybind_labels()


func set_keymap(keymap_index):
	Data.player_keymap = Data.keymaps[keymap_index]
	Data.player_keymap.apply()
	load_keybind_labels()


func load_keybind_labels():
	for box in keybind_boxes:
		box.queue_free()
	keybind_boxes.clear()
	for action in InputMap.get_actions():
		if !action.begins_with("ui_"):
			var box = HBoxContainer.new()
			var alabel = Label.new()
			var elabel = Button.new()
			alabel.text = action
			if InputMap.action_get_events(action).size() > 0:
				elabel.text = InputMap.action_get_events(action)[0].as_text()
			elabel.size_flags_horizontal += Control.SIZE_EXPAND
			alabel.size_flags_horizontal += Control.SIZE_EXPAND
			alabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			alabel.size_flags_stretch_ratio = 2.0
			#elabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			box.add_child(alabel)
			box.add_child(elabel)
			elabel.pressed.connect(_on_keybind_button_pressed.bind(elabel))
			keybind_buttons[elabel] = action
			$ScrollContainer/VBoxContainer.add_child(box)
			keybind_boxes.append(box)


func _on_keybind_button_pressed(value: Button) -> void:
	selected_button = keybind_buttons[value]
	selected_button_button = value
	var popup = keybind_popup.instantiate()
	popup.event_detected.connect(change_key)
	Game.UILayer.add_child(popup)


func change_key(event: InputEvent):
	Data.player_keymap.replace_action_event(selected_button, event)
	selected_button_button.text = event.as_text()
