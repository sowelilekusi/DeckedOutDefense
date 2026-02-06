class_name GameEndScreen extends PanelContainer

signal pressed_continue()

@export var box: PackedScene

@export var outcome_label: Label
@export var winrate_label: Label
@export var total_games_label: Label
@export var total_wins_label: Label
@export var total_losses_label: Label
@export var undefeated_enemies: VBoxContainer

var game_manager: GameManager


func won_game() -> void:
	$VBoxContainer/Buttons/ContinueButton.visible = true
	$VBoxContainer/Buttons/PlayButton.visible = false


func _ready() -> void:
	winrate_label.text = str(Data.save_data.winrate) + "%"
	total_games_label.text = str(Data.save_data.wins + Data.save_data.losses)
	total_wins_label.text = str(Data.save_data.wins)
	total_losses_label.text = str(Data.save_data.losses)
	if game_manager:
		set_wave()


func set_wave() -> void:
	for wave_key: int in game_manager.stats.enemies_undefeated:
		var spawned_box: EnemyRow = box.instantiate() as EnemyRow
		undefeated_enemies.add_child(spawned_box)
		spawned_box.set_wave(wave_key)
		for enemy_key: Enemy in game_manager.stats.enemies_undefeated[wave_key]:
			spawned_box.add_enemy_tag(enemy_key, game_manager.stats.enemies_undefeated[wave_key][enemy_key])


func set_outcome_message(message: String) -> void:
	outcome_label.text = message


func _on_quit_button_pressed() -> void:
	game_manager.scene_switch_main_menu()
	queue_free()


func _on_play_button_pressed() -> void:
	if game_manager.gamemode.daily == false and !game_manager.gamemode.seeded:
		game_manager.gamemode.rng_seed = randi()
	game_manager.setup()
	game_manager.start()
	queue_free()


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()


func _on_continue_button_pressed() -> void:
	pressed_continue.emit()
	queue_free()
