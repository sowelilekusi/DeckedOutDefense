extends Control

var confirmation_popup_scene = preload("res://Scenes/Menus/confirmation_popup.tscn")
var text_input_popup_scene = preload("res://Scenes/Menus/text_input_popup.tscn")
var multiplayer_lobby_scene_path = "res://Scenes/multiplayer_lobby.tscn"
var options_menu_scene = preload("res://Scenes/Menus/options_menu.tscn")
@export var bg_level : Level


func _ready() -> void:
	$ProfileEditor/VBoxContainer/HBoxContainer/DisplayName.text = Data.player_profile.display_name
	bg_level.a_star_graph_3d.make_grid()
	bg_level.a_star_graph_3d.find_path()
	bg_level.a_star_graph_3d.build_random_maze(50)
	bg_level.a_star_graph_3d.place_random_towers(20)
	bg_level.a_star_graph_3d.disable_all_tower_frames()
	var new_wave = WaveManager.generate_wave(400, bg_level.enemy_pool)
	for spawn in bg_level.enemy_spawns:
		spawn.signal_for_after_enemy_died = enemy_died
		spawn.signal_for_after_enemy_reached_goal = damage_goal
		spawn.signal_for_when_enemy_spawns.connect(increase_enemy_count)
		spawn.spawn_wave(new_wave)

func enemy_died(_some_arg):
	pass
func damage_goal():
	pass
func increase_enemy_count():
	pass


func _on_display_name_edit_pressed() -> void:
	var popup = text_input_popup_scene.instantiate() as TextInputPopup
	popup.set_popup(Data.player_profile.display_name, "Display Name", "Confirm")
	popup.completed.connect(change_profile_display_name)
	add_child(popup)


func change_profile_display_name(display_name):
	$ProfileEditor/VBoxContainer/HBoxContainer/DisplayName.text = display_name
	Data.player_profile.set_display_name(display_name)


func _on_quit_button_pressed() -> void:
	var popup = confirmation_popup_scene.instantiate() as ConfirmationPopup
	popup.set_popup("Are you sure you want to quit?", "Yes", "No")
	popup.completed.connect(quit_game)
	add_child(popup)


func quit_game(confirmation):
	if confirmation:
		get_tree().quit()


func _on_play_button_pressed() -> void:
	Game.scene_switch_to_singleplayer_lobby()


func _on_options_button_pressed() -> void:
	var menu = options_menu_scene.instantiate()
	add_child(menu)


func _on_multiplayer_button_pressed() -> void:
	Game.scene_switch_to_multiplayer_lobby()
