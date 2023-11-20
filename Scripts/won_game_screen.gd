extends Control


func _on_quit_button_pressed() -> void:
	Game.scene_switch_main_menu()
	queue_free()


func _on_play_button_pressed() -> void:
	Game.restart_game()
	queue_free()
