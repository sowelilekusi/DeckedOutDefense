extends Control


func _on_quit_button_pressed() -> void:
	Game.quit_to_desktop()


func _on_restart_button_pressed() -> void:
	Game.restart_game()
	queue_free()
