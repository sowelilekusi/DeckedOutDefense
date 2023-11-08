extends Control

var confirmation_popup_scene = preload("res://Scenes/Menus/confirmation_popup.tscn")
var text_input_popup_scene = preload("res://Scenes/Menus/text_input_popup.tscn")
var multiplayer_lobby_scene_path = "res://Scenes/multiplayer_lobby.tscn"
var options_menu_scene = preload("res://Scenes/Menus/options_menu.tscn")

func _ready() -> void:
	$ProfileEditor/VBoxContainer/HBoxContainer/DisplayName.text = Data.player_profile.display_name


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
