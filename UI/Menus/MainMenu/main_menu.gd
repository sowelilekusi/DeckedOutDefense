class_name MainMenu extends Control

signal singleplayer_game_requested
signal multiplayer_game_requested

@export var bg_level: Level
@export var game_select_menu: Control
@export var main_controls: Control
@export var seed_entry: LineEdit
@export var profile_controls: Control
@export var mods_controls: ModMenu

var game: GameManager
var gamemode: GameMode = GameMode.new()

var confirmation_popup_scene: PackedScene = preload("res://Scenes/Menus/confirmation_popup.tscn")
var text_input_popup_scene: PackedScene = preload("res://Scenes/Menus/text_input_popup.tscn")
var multiplayer_lobby_scene_path: String = "res://Scenes/multiplayer_lobby.tscn"
var options_menu_scene: PackedScene = preload("res://UI/Menus/OptionsMenu/options_menu.tscn")
var temp_data: SaveData
var hovered_level_config: LevelConfig


func _ready() -> void:
	load_stats(Data.save_data)
	#bg_level.a_star_graph_3d.make_grid()
	#bg_level.a_star_graph_3d.find_path()
	#bg_level.a_star_graph_3d.build_random_maze(70)
	#bg_level.a_star_graph_3d.place_random_towers(30)
	#bg_level.a_star_graph_3d.disable_all_tower_frames()
	#Game.level = bg_level
	#WaveManager.generate_wave(WaveManager.calculate_spawn_power(50, 4), bg_level.enemy_pool, bg_level.enemy_spawns)
	#for spawn: EnemySpawner in bg_level.enemy_spawns:
	#	spawn.enemy_died_callback = enemy_died
	#	spawn.enemy_reached_goal_callback = damage_goal
	#	spawn.enemy_spawned.connect(increase_enemy_count)
	#	spawn.spawn_wave()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		return_to_main_menu()


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
	popup.set_popup("PROMPT_QUIT", "BUTTON_CONFIRM", "BUTTON_CANCEL")
	popup.completed.connect(quit_game)
	add_child(popup)


func quit_game(confirmation: bool) -> void:
	if confirmation:
		get_tree().quit()


func _on_options_button_pressed() -> void:
	var menu: OptionsMenu = options_menu_scene.instantiate()
	menu.game_manager = game
	add_child(menu)


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()


func start_game() -> void:
	game.gamemode = gamemode
	if !gamemode.multiplayer:
		singleplayer_game_requested.emit()
	else:
		level_selected($PanelContainer.levels[0], 0)
		multiplayer_game_requested.emit()


func _on_play_button_pressed() -> void:
	gamemode.multiplayer = false
	open_game_menu()



#TODO: Clearn this part up
#TODO: new lobby system >>

#var lobby_panel: PanelContainer
func _on_multiplayer_button_pressed() -> void:
	gamemode.multiplayer = true
	start_game()
	#if !lobby_panel:
		#lobby_panel = PanelContainer.new()
		#add_child(lobby_panel)
	#lobby_panel.visible = true
	#lobby_panel.anchor_top = 0.1
	#lobby_panel.anchor_left = 0.3
	#lobby_panel.anchor_right = 0.7
	#lobby_panel.anchor_bottom = 0.9
	#gamemode.multiplayer = true
	#open_game_menu()






func open_game_menu() -> void:
	main_controls.visible = false
	game_select_menu.visible = true


func _on_back_button_pressed() -> void:
	main_controls.visible = true
	game_select_menu.visible = false


func return_to_main_menu() -> void:
	main_controls.visible = true
	game_select_menu.visible = false
	profile_controls.visible = false
	mods_controls.visible = false


func generate_seed() -> int:
	var seed_generated: int = 0
	if seed_entry.text != "":
		if seed_entry.text.is_valid_int():
			seed_generated = int(seed_entry.text)
		else:
			seed_generated = hash(seed_entry.text)
		gamemode.seeded = true
	else:
		seed_generated = randi()
	return seed_generated


func level_selected(level: LevelConfig, side: int) -> void:
	gamemode.endless = true if side == 1 else false
	gamemode.rng_seed = generate_seed() if gamemode.endless else level.game_seed
	gamemode.daily = false
	if gamemode.endless:
		level.allowed_cards = level.hero_class.deck
		level.waves = []
	game.level_config = level
	#start_game()


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
	$ProfileManager/VBoxContainer/Stats/Games/Label2.text = str(Data.save_data.wins + Data.save_data.losses)
	$ProfileManager/VBoxContainer/Stats/Wins/Label2.text = str(Data.save_data.wins)
	$ProfileManager/VBoxContainer/Stats/Losses/Label2.text = str(Data.save_data.losses)
	$ProfileManager/VBoxContainer/Stats/Winrate/Label2.text = str(Data.save_data.winrate) + "%"
	$ProfileManager/VBoxContainer/Stats/EngineerCardsBought/Label2.text = str(stats.engineer_cards_bought)
	$ProfileManager/VBoxContainer/Stats/MageCardsBought/Label2.text = str(stats.mage_cards_bought)


func _on_achievements_back_button_pressed() -> void:
	$AchievementsMenu.visible = false


func _on_achievements_button_pressed() -> void:
	$AchievementsMenu.visible = true


func _on_profile_manager_cancel_pressed() -> void:
	profile_controls.visible = false
	main_controls.visible = true


func _on_profile_manager_confirm_pressed() -> void:
	profile_controls.visible = false
	main_controls.visible = true
	if $ProfileManager/VBoxContainer/DisplayName/LineEdit.text != "":
		change_profile_display_name($ProfileManager/VBoxContainer/DisplayName/LineEdit.text)
		$ProfileManager/VBoxContainer/DisplayName/LineEdit.text = ""
	#Data.save_data = temp_data
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
	main_controls.visible = true
	mods_controls.visible = false


func _on_confirm_mods_pressed() -> void:
	mods_controls.load_mod_list()
	main_controls.visible = true
	mods_controls.visible = false


func _on_stats_button_pressed() -> void:
	main_controls.visible = false
	profile_controls.visible = true
