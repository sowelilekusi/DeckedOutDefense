class_name GameplayOptionsMenu
extends VBoxContainer

@export var resolution_drop_down: OptionButton
@export var look_sens_slider: HSlider
@export var look_sens_input: SpinBox
@export var toggle_sprint_checkbox: CheckButton
@export var invert_lookY: CheckButton
@export var invert_lookX: CheckButton
@export var fixed_minimap: CheckButton
@export var tower_damage: Button
@export var self_damage: Button
@export var party_damage: Button
@export var status_damage: Button
@export var show_shield: Button


func _ready() -> void:
	#resolution_drop_down.add_item("320x240")
	#resolution_drop_down.add_item("1920x1080")
	#$MouseSens2/HBoxContainer/SpinBox.value = get_window().content_scale_factor
	#$MouseSens2/HBoxContainer/HSlider.value = get_window().content_scale_factor
	look_sens_slider.value = Data.preferences.mouse_sens
	look_sens_input.value = Data.preferences.mouse_sens
	toggle_sprint_checkbox.button_pressed = Data.preferences.toggle_sprint
	invert_lookY.button_pressed = Data.preferences.invert_lookY
	invert_lookX.button_pressed = Data.preferences.invert_lookX
	fixed_minimap.button_pressed = Data.preferences.fixed_minimap
	tower_damage.button_pressed = Data.preferences.display_tower_damage_indicators
	self_damage.button_pressed = Data.preferences.display_self_damage_indicators
	party_damage.button_pressed = Data.preferences.display_party_damage_indicators
	status_damage.button_pressed = Data.preferences.display_status_effect_damage_indicators
	show_shield.button_pressed = Data.preferences.always_show_shield_ui


func save() -> void:
	Data.preferences.mouse_sens = look_sens_slider.value
	Data.preferences.toggle_sprint = toggle_sprint_checkbox.button_pressed
	Data.preferences.invert_lookY = invert_lookY.button_pressed
	Data.preferences.invert_lookX = invert_lookX.button_pressed
	Data.preferences.fixed_minimap = fixed_minimap.button_pressed
	Data.preferences.display_tower_damage_indicators = tower_damage.button_pressed
	Data.preferences.display_self_damage_indicators = self_damage.button_pressed
	Data.preferences.display_party_damage_indicators = party_damage.button_pressed
	Data.preferences.display_status_effect_damage_indicators = status_damage.button_pressed
	Data.preferences.always_show_shield_ui = show_shield.button_pressed


func _on_mouse_sens_spin_box_value_changed(value: float) -> void:
	look_sens_slider.value = value


func _on_mouse_sens_h_slider_value_changed(value: float) -> void:
	look_sens_input.value = value


func _on_option_button_item_selected(index: int) -> void:
	#print(index)
	if index == 0:
		get_tree().root.size = Vector2i(320, 240)
		#DisplayServer.window_set_size(Vector2i(320, 240))
		#print(get_tree().root.size)
	if index == 1:
		get_tree().root.size = Vector2i(1920, 1080)
		#DisplayServer.window_set_size(Vector2i(1920, 1080))
		#print(get_tree().root.size)


func _on_spin_box_value_changed(value: float) -> void:
	get_window().content_scale_factor = value


func _on_h_slider_value_changed(value: float) -> void:
	get_window().content_scale_factor = value
