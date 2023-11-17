extends VBoxContainer
class_name GraphicsOptionsMenu

@export var fov_input : SpinBox
@export var fov_slider : HSlider
@export var vsync_dropdown : OptionButton
@export var aa_dropdown : OptionButton
@export var window_dropdown : OptionButton


func _ready():
	fov_input.value = Data.graphics.hfov
	fov_slider.value = Data.graphics.hfov
	vsync_dropdown.selected = Data.graphics.vsync_mode
	aa_dropdown.selected = Data.graphics.aa_mode


func save():
	Data.graphics.hfov = fov_slider.value
	Data.graphics.vsync_mode = vsync_dropdown.selected
	Data.graphics.aa_mode = aa_dropdown.selected
	Data.graphics.windowed_mode = window_dropdown.selected


func _on_fov_spin_box_value_changed(value: float) -> void:
	if value < 40.0:
		value = 40.0
	if value > 160.0:
		value = 160.0
	fov_slider.value = value
	Data.graphics.hfov = value


func _on_fov_h_slider_value_changed(value: float) -> void:
	fov_input.value = value
	Data.graphics.hfov = value
