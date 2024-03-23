class_name MainMenu extends Control

@export var bg_level: Level

var confirmation_popup_scene: PackedScene = preload("res://Scenes/Menus/confirmation_popup.tscn")
var text_input_popup_scene: PackedScene = preload("res://Scenes/Menus/text_input_popup.tscn")
var multiplayer_lobby_scene_path: String = "res://Scenes/multiplayer_lobby.tscn"
var options_menu_scene: PackedScene = preload("res://Scenes/Menus/options_menu.tscn")


func _ready() -> void:
	$ProfileEditor/VBoxContainer/HBoxContainer/DisplayName.text = Data.player_profile.display_name
	bg_level.a_star_graph_3d.make_grid()
	bg_level.a_star_graph_3d.find_path()
	bg_level.a_star_graph_3d.build_random_maze(50)
	bg_level.a_star_graph_3d.place_random_towers(20)
	bg_level.a_star_graph_3d.disable_all_tower_frames()
	Game.level = bg_level
	var new_wave: Dictionary = WaveManager.generate_wave(400, bg_level.enemy_pool)
	for spawn: EnemySpawner in bg_level.enemy_spawns:
		spawn.enemy_died_callback = enemy_died
		spawn.enemy_reached_goal_callback = damage_goal
		spawn.enemy_spawned.connect(increase_enemy_count)
		spawn.spawn_wave(new_wave)


#these exist purely to make the enemies that spawn on the main menu happy
func enemy_died(_some_arg: Enemy) -> void:
	pass
func damage_goal(_some_arg1: int, _some_arg2: int) -> void:
	pass
func increase_enemy_count() -> void:
	pass


func _on_display_name_edit_pressed() -> void:
	var popup: TextInputPopup = text_input_popup_scene.instantiate() as TextInputPopup
	popup.set_popup(Data.player_profile.display_name, "Display Name", "Confirm")
	popup.completed.connect(change_profile_display_name)
	add_child(popup)


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


func _on_play_button_pressed() -> void:
	Game.scene_switch_to_singleplayer_lobby()


func _on_options_button_pressed() -> void:
	var menu: OptionsMenu = options_menu_scene.instantiate()
	add_child(menu)


func _on_multiplayer_button_pressed() -> void:
	Game.scene_switch_to_multiplayer_lobby()


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()
