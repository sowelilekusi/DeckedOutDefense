class_name OptionsMenu extends Control

@export var gameplay: GameplayOptionsMenu
@export var graphics: GraphicsOptionsMenu
@export var keybinds: KeybindsOptionsMenu


func _on_cancel_pressed() -> void:
	queue_free()


func _on_confirm_pressed() -> void:
	gameplay.save()
	graphics.save()
	keybinds.save()
	Data.graphics.apply_graphical_settings(get_viewport())
	Data.graphics.save_profile_to_disk()
	Data.audio.apply_audio_settings()
	Data.audio.save_profile_to_disk()
	Data.preferences.save_profile_to_disk()
	Data.keymap_data.apply()
	Data.keymap_data.save_to_disc()
	#Data.player_keymap.save_profile_to_disk()
	#Data.player_controller_keymap.append_input_map()
	queue_free()


func _on_button_hovered() -> void:
	$AudioStreamPlayer.play()
