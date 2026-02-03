class_name GraphicsOptionsMenu
extends VBoxContainer

@export var fov_input: SpinBox
@export var fov_slider: HSlider
@export var vsync_dropdown: OptionButton
@export var aa_dropdown: OptionButton
@export var window_dropdown: OptionButton
@export var vertex_jitter_input: SpinBox
@export var vertex_jitter_slider: HSlider
@export var affine_warping_input: SpinBox
@export var affine_warping_slider: HSlider


func _ready() -> void:
	fov_input.value = Data.graphics.hfov
	fov_slider.value = Data.graphics.hfov
	vsync_dropdown.selected = Data.graphics.vsync_mode
	aa_dropdown.selected = Data.graphics.aa_mode
	window_dropdown.selected = Data.graphics.windowed_mode
	vertex_jitter_input.value = Data.graphics.vertex_jitter
	vertex_jitter_slider.value = Data.graphics.vertex_jitter
	affine_warping_input.value = Data.graphics.affine_warping
	affine_warping_slider.value = Data.graphics.affine_warping


func save() -> void:
	Data.graphics.hfov = fov_slider.value
	Data.graphics.vsync_mode = vsync_dropdown.selected
	Data.graphics.aa_mode = aa_dropdown.selected
	Data.graphics.windowed_mode = window_dropdown.selected
	Data.graphics.vertex_jitter = vertex_jitter_slider.value
	Data.graphics.affine_warping = affine_warping_slider.value


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


func _on_vertex_jitter_spin_box_value_changed(value: float) -> void:
	if value < 0.0:
		value = 0.0
	if value > 1.0:
		value = 1.0
	vertex_jitter_slider.value = value
	Data.graphics.vertex_jitter = value


func _on_vertex_jitter_h_slider_value_changed(value: float) -> void:
	vertex_jitter_input.value = value
	Data.graphics.vertex_jitter = value


func _on_affine_warping_spin_box_value_changed(value: float) -> void:
	if value < 0.0:
		value = 0.0
	if value > 1.0:
		value = 1.0
	affine_warping_slider.value = value
	Data.graphics.affine_warping = value


func _on_affine_warping_h_slider_value_changed(value: float) -> void:
	affine_warping_input.value = value
	Data.graphics.affine_warping = value
