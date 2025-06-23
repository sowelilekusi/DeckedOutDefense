class_name PauseMenu extends Control

signal closed
signal quit_to_main_menu_pressed
signal quit_to_desktop_pressed

var options_menu_scene: PackedScene = preload("res://Scenes/Menus/options_menu.tscn")
var confirmation_popup_scene: PackedScene = preload("res://Scenes/Menus/confirmation_popup.tscn")
var game_manager: GameManager


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		accept_event()
		_on_resume_pressed()


func _on_resume_pressed() -> void:
	closed.emit()
	queue_free()


func _on_options_pressed() -> void:
	var menu: OptionsMenu = options_menu_scene.instantiate()
	menu.game_manager = game_manager
	add_child(menu)


func _on_quit_to_main_menu_pressed() -> void:
	var popup: ConfirmationPopup = confirmation_popup_scene.instantiate() as ConfirmationPopup
	popup.set_popup("Are you sure you want to quit and return to main menu?", "Yes", "No")
	popup.completed.connect(return_to_menu)
	add_child(popup)


func return_to_menu(confirmation: bool) -> void:
	if confirmation:
		quit_to_main_menu_pressed.emit()


func _on_quit_to_desktop_pressed() -> void:
	var popup: ConfirmationPopup = confirmation_popup_scene.instantiate() as ConfirmationPopup
	popup.set_popup("Are you sure you want to quit?", "Yes", "No")
	popup.completed.connect(quit_game)
	add_child(popup)


func quit_game(confirmation: bool) -> void:
	if confirmation:
		quit_to_desktop_pressed.emit()


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()
