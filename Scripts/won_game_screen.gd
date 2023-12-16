extends Control


func _ready() -> void:
	var wins = float(Data.save_stats.twenty_game_history.count(true))
	var games = float(Data.save_stats.twenty_game_history.size())
	var winrate = int((wins / games) * 100.0)
	$Label2.text = "Your 20-game winrate is now: " + str(winrate) + "%!"
	$Label3.text = "Total games: " + str(Data.save_stats.wins + Data.save_stats.losses)
	$Label4.text = "Total wins: " + str(Data.save_stats.wins)
	$Label5.text = "Total losses: " + str(Data.save_stats.losses)


func _on_quit_button_pressed() -> void:
	Game.scene_switch_main_menu()
	queue_free()


func _on_play_button_pressed() -> void:
	Game.restart_game()
	queue_free()


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()
