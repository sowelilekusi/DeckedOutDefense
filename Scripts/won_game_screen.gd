class_name WonGameScreen extends Control

@export var box: PackedScene


func _ready() -> void:
	var wins: int = Data.save_stats.twenty_game_history.count(true)
	var games: int = Data.save_stats.twenty_game_history.size()
	var winrate: int = int((float(wins) / float(games)) * 100.0)
	$Label2.text = "Your 20-game winrate is now: " + str(winrate) + "%!"
	$Label3.text = "Total games: " + str(Data.save_stats.wins + Data.save_stats.losses)
	$Label4.text = "Total wins: " + str(Data.save_stats.wins)
	$Label5.text = "Total losses: " + str(Data.save_stats.losses)
	for wave_key: int in Game.stats.enemies_undefeated:
		var spawned_box: EnemyBox = box.instantiate() as EnemyBox
		$VBoxContainer.add_child(spawned_box)
		spawned_box.set_wave(wave_key)
		for enemy_key: Enemy in Game.stats.enemies_undefeated[wave_key]:
			spawned_box.add_enemy_tag(enemy_key, Game.stats.enemies_undefeated[wave_key][enemy_key])


func _on_quit_button_pressed() -> void:
	Game.scene_switch_main_menu()
	queue_free()


func _on_play_button_pressed() -> void:
	Game.restart_game()
	queue_free()


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()
