extends Control
class_name OptionsMenu

@export var keybind_popup : PackedScene
@export var look_sens_slider : HSlider
@export var look_sens_input : SpinBox
@export var toggle_sprint_checkbox : CheckButton
@export var vsync_dropdown : OptionButton
@export var aa_dropdown : OptionButton
@export var window_dropdown : OptionButton
@export var invert_lookY : CheckButton
@export var invert_lookX : CheckButton
@export var fov_input : SpinBox
@export var fov_slider : HSlider
@export var fixed_minimap : CheckButton
var keybind_boxes = []
var keybind_buttons = {}
var key_event
var selected_button
var selected_button_button
var listening_for_key := false

func _ready():
	look_sens_slider.value = Data.preferences.mouse_sens
	look_sens_input.value = Data.preferences.mouse_sens
	toggle_sprint_checkbox.button_pressed = Data.preferences.toggle_sprint
	vsync_dropdown.selected = Data.preferences.vsync_mode
	aa_dropdown.selected = Data.preferences.aa_mode
	invert_lookY.button_pressed = Data.preferences.invert_lookY
	invert_lookX.button_pressed = Data.preferences.invert_lookX
	fov_input.value = Data.preferences.hfov
	fov_slider.value = Data.preferences.hfov
	fixed_minimap.button_pressed = Data.preferences.fixed_minimap
	
	for index in Data.keymaps.size():
		var map = Data.keymaps[index]
		var button = Button.new()
		button.text = map.title
		button.pressed.connect(set_keymap.bind(index))
		$VBoxContainer/TabContainer/Keybinds/HBoxContainer.add_child(button)
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
			$VBoxContainer/TabContainer/Keybinds/ScrollContainer/VBoxContainer.add_child(box)
			keybind_boxes.append(box)


func _on_cancel_pressed() -> void:
	queue_free()


func _on_confirm_pressed() -> void:
	Data.preferences.mouse_sens = look_sens_slider.value
	Data.preferences.toggle_sprint = toggle_sprint_checkbox.button_pressed
	Data.preferences.vsync_mode = vsync_dropdown.selected
	Data.preferences.aa_mode = aa_dropdown.selected
	Data.preferences.windowed_mode = window_dropdown.selected
	Data.preferences.invert_lookY = invert_lookY.button_pressed
	Data.preferences.invert_lookX = invert_lookX.button_pressed
	Data.preferences.fixed_minimap = fixed_minimap.button_pressed
	Data.preferences.apply_graphical_settings(get_viewport())
	Data.preferences.save_profile_to_disk()
	Data.player_keymap.save_profile_to_disk()
	queue_free()


func _on_mouse_sens_spin_box_value_changed(value: float) -> void:
	look_sens_slider.value = value


func _on_mouse_sens_h_slider_value_changed(value: float) -> void:
	look_sens_input.value = value


func _on_fov_spin_box_value_changed(value: float) -> void:
	if value < 40.0:
		value = 40.0
	if value > 160.0:
		value = 160.0
	fov_slider.value = value
	Data.preferences.hfov = value


func _on_fov_h_slider_value_changed(value: float) -> void:
	fov_input.value = value
	Data.preferences.hfov = value


func _on_keybind_button_pressed(value: Button) -> void:
	selected_button = keybind_buttons[value]
	selected_button_button = value
	var popup = keybind_popup.instantiate()
	popup.event_detected.connect(change_key)
	add_child(popup)


func change_key(event: InputEvent):
	Data.player_keymap.replace_action_event(selected_button, event)
	selected_button_button.text = event.as_text()
