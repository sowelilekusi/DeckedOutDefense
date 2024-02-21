class_name AudioOptions extends VBoxContainer

@export var master_input: SpinBox
@export var master_slider: HSlider
@export var music_input: SpinBox
@export var music_slider: HSlider
@export var sfx_input: SpinBox
@export var sfx_slider: HSlider


func _ready() -> void:
	master_input.value = Data.audio.master
	master_slider.value = Data.audio.master
	music_input.value = Data.audio.music
	music_slider.value = Data.audio.music
	sfx_input.value = Data.audio.sfx
	sfx_slider.value = Data.audio.sfx


func _on_master_spin_box_value_changed(value: float) -> void:
	master_slider.value = value
	Data.audio.master = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100.0))


func _on_master_h_slider_value_changed(value: float) -> void:
	master_input.value = value
	Data.audio.master = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100.0))


func _on_music_spin_box_value_changed(value: float) -> void:
	music_slider.value = value
	Data.audio.music = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value / 100.0))


func _on_music_h_slider_value_changed(value: float) -> void:
	music_input.value = value
	Data.audio.music = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value / 100.0))


func _on_sfx_spin_box_value_changed(value: float) -> void:
	sfx_slider.value = value
	Data.audio.sfx = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100.0))


func _on_sfx_h_slider_value_changed(value: float) -> void:
	sfx_input.value = value
	Data.audio.sfx = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100.0))
