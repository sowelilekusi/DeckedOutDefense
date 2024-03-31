class_name GameEndScreen extends PanelContainer

@export var box: PackedScene

@export var outcome_label: Label
@export var winrate_label: Label
@export var total_games_label: Label
@export var total_wins_label: Label
@export var total_losses_label: Label
@export var undefeated_enemies: VBoxContainer


func _ready() -> void:
	var wins: int = Data.save_stats.twenty_game_history.count(true)
	var games: int = Data.save_stats.twenty_game_history.size()
	var winrate: int = int((float(wins) / float(games)) * 100.0)
	winrate_label.text = "Your 20-game winrate is now: " + str(winrate) + "%!"
	total_games_label.text = "Total games: " + str(Data.save_stats.wins + Data.save_stats.losses)
	total_wins_label.text = "Total wins: " + str(Data.save_stats.wins)
	total_losses_label.text = "Total losses: " + str(Data.save_stats.losses)
	for wave_key: int in Game.stats.enemies_undefeated:
		var spawned_box: EnemyBox = box.instantiate() as EnemyBox
		undefeated_enemies.add_child(spawned_box)
		spawned_box.set_wave(wave_key)
		for enemy_key: Enemy in Game.stats.enemies_undefeated[wave_key]:
			spawned_box.add_enemy_tag(enemy_key, Game.stats.enemies_undefeated[wave_key][enemy_key])


func set_outcome_message(message: String) -> void:
	outcome_label.text = message


func _on_quit_button_pressed() -> void:
	Game.scene_switch_main_menu()
	queue_free()


func _on_play_button_pressed() -> void:
	Game.setup()
	Game.start()
	queue_free()


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()
