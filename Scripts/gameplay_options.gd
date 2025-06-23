class_name GameplayOptionsMenu
extends VBoxContainer

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


func _ready() -> void:
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


func _on_mouse_sens_spin_box_value_changed(value: float) -> void:
	look_sens_slider.value = value


func _on_mouse_sens_h_slider_value_changed(value: float) -> void:
	look_sens_input.value = value
