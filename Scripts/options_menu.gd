extends Control
class_name OptionsMenu


func _on_cancel_pressed() -> void:
	queue_free()


func _on_confirm_pressed() -> void:
	Data.graphics.apply_graphical_settings(get_viewport())
	Data.graphics.save_profile_to_disk()
	Data.preferences.save_profile_to_disk()
	Data.player_keymap.save_profile_to_disk()
	queue_free()
