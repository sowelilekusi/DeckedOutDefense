class_name MainMenu extends Control

@export var bg_level: Level
@export var game_select_menu: Control
@export var main_controls: Control
@export var seed_entry: LineEdit
@export var profile_controls: Control
@export var mods_controls: ModMenu

var gamemode: GameMode = GameMode.new()

var confirmation_popup_scene: PackedScene = preload("res://Scenes/Menus/confirmation_popup.tscn")
var text_input_popup_scene: PackedScene = preload("res://Scenes/Menus/text_input_popup.tscn")
var multiplayer_lobby_scene_path: String = "res://Scenes/multiplayer_lobby.tscn"
var options_menu_scene: PackedScene = preload("res://Scenes/Menus/options_menu.tscn")
var temp_data: SaveData


func _ready() -> void:
	$ProfileEditor/VBoxContainer/HBoxContainer/DisplayName.text = Data.player_profile.display_name
	load_stats(Data.save_data)
	#bg_level.a_star_graph_3d.make_grid()
	#bg_level.a_star_graph_3d.find_path()
	#bg_level.a_star_graph_3d.build_random_maze(70)
	#bg_level.a_star_graph_3d.place_random_towers(30)
	#bg_level.a_star_graph_3d.disable_all_tower_frames()
	Game.level = bg_level
	#WaveManager.generate_wave(WaveManager.calculate_spawn_power(50, 4), bg_level.enemy_pool, bg_level.enemy_spawns)
	#for spawn: EnemySpawner in bg_level.enemy_spawns:
	#	spawn.enemy_died_callback = enemy_died
	#	spawn.enemy_reached_goal_callback = damage_goal
	#	spawn.enemy_spawned.connect(increase_enemy_count)
	#	spawn.spawn_wave()


#these exist purely to make the enemies that spawn on the main menu happy
func enemy_died(_some_arg: Enemy) -> void:
	pass
func damage_goal(_some_arg1: Enemy, _some_arg2: int) -> void:
	pass
func increase_enemy_count() -> void:
	pass


func _on_display_name_edit_pressed() -> void:
	$ProfileManager.visible = true
	$ProfileManager/VBoxContainer/DisplayName/LineEdit.placeholder_text = Data.player_profile.display_name
	temp_data = SaveData.load_from_disk(0)


func change_profile_display_name(display_name: String) -> void:
	$ProfileEditor/VBoxContainer/HBoxContainer/DisplayName.text = display_name
	Data.player_profile.set_display_name(display_name)


func _on_quit_button_pressed() -> void:
	var popup: ConfirmationPopup = confirmation_popup_scene.instantiate() as ConfirmationPopup
	popup.set_popup("Are you sure you want to quit?", "Yes", "No")
	popup.completed.connect(quit_game)
	add_child(popup)


func quit_game(confirmation: bool) -> void:
	if confirmation:
		get_tree().quit()


func _on_options_button_pressed() -> void:
	var menu: OptionsMenu = options_menu_scene.instantiate()
	add_child(menu)


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()


func start_game() -> void:
	Game.level = null
	Game.gamemode = gamemode
	if gamemode.multiplayer:
		Game.scene_switch_to_multiplayer_lobby()
	else:
		Game.scene_switch_to_singleplayer_lobby()


func _on_play_button_pressed() -> void:
	gamemode.multiplayer = false
	open_game_menu()


func _on_multiplayer_button_pressed() -> void:
	gamemode.multiplayer = true
	open_game_menu()


func open_game_menu() -> void:
	main_controls.visible = false
	game_select_menu.visible = true
	

func _on_back_button_pressed() -> void:
	main_controls.visible = true
	game_select_menu.visible = false


func generate_seed() -> void:
	if seed_entry.text != "":
		if seed_entry.text.is_valid_int():
			gamemode.rng_seed = int(seed_entry.text)
		else:
			gamemode.rng_seed = hash(seed_entry.text)
		gamemode.seeded = true
	else:
		gamemode.rng_seed = randi()


func _on_standard_button_pressed() -> void:
	generate_seed()
	gamemode.endless = false
	gamemode.daily = false
	start_game()


func _on_daily_button_pressed() -> void:
	gamemode.rng_seed = hash(Time.get_date_string_from_system(true))
	gamemode.endless = false
	gamemode.daily = true
	start_game()


func _on_endless_button_pressed() -> void:
	generate_seed()
	gamemode.endless = true
	gamemode.daily = false
	start_game()


func _on_changelog_button_pressed() -> void:
	main_controls.visible = true
	profile_controls.visible = true
	$Changelog.queue_free()


func load_stats(stats: SaveData) -> void:
	$ProfileManager/VBoxContainer/Stats/Wins/Label2.text = str(stats.wins)
	$ProfileManager/VBoxContainer/Stats/Losses/Label2.text = str(stats.losses)
	$ProfileManager/VBoxContainer/Stats/Winrate/Label2.text = str(stats.winrate) + "%"
	$ProfileManager/VBoxContainer/Stats/EngineerCardsBought/Label2.text = str(stats.engineer_cards_bought)
	$ProfileManager/VBoxContainer/Stats/MageCardsBought/Label2.text = str(stats.mage_cards_bought)


func _on_achievements_back_button_pressed() -> void:
	$AchievementsMenu.visible = false


func _on_achievements_button_pressed() -> void:
	$AchievementsMenu.visible = true


func _on_profile_manager_cancel_pressed() -> void:
	$ProfileManager.visible = false


func _on_profile_manager_confirm_pressed() -> void:
	$ProfileManager.visible = false
	if $ProfileManager/VBoxContainer/DisplayName/LineEdit.text != "":
		change_profile_display_name($ProfileManager/VBoxContainer/DisplayName/LineEdit.text)
		$ProfileManager/VBoxContainer/DisplayName/LineEdit.text = ""
	Data.save_data = temp_data
	Data.save_data.save_to_disc()


func _on_unlock_all_pressed() -> void:
	temp_data.unlock_all_content()


func _on_lock_all_pressed() -> void:
	temp_data.lock_all_content()


func _on_mods_button_pressed() -> void:
	profile_controls.visible = false
	main_controls.visible = false
	mods_controls.visible = true


func _on_cancel_mods_pressed() -> void:
	profile_controls.visible = true
	main_controls.visible = true
	mods_controls.visible = false


func _on_confirm_mods_pressed() -> void:
	mods_controls.load_mod_list()
