class_name ServerForm
extends PanelContainer

signal connect_button_pressed
signal host_button_pressed

@export var ip_entry: LineEdit
@export var port_entry: LineEdit
@export var host_button: Button
@export var join_button: Button
@export var ip_field: HBoxContainer
@export var port_field: HBoxContainer
@export var players_field: HBoxContainer
@export var start_button: Button

var game_manager: GameManager
var menu: int = 0
var hosting: bool = false

var ip: String :
	get:
		return ip_entry.text if ip_entry.text != "" else "localhost"
	set(_value):
		return

var port: int :
	get:
		return int(port_entry.text) if port_entry.text != "" and port_entry.text.is_valid_int() else Data.DEFAULT_SERVER_PORT
	set(_value):
		return

var max_players: int :
	get:
		return int($VBoxContainer/PlayersField/HSlider.value)
	set(_value):
		return


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()


func _on_button_pressed() -> void:
	if menu == 0:
		game_manager.scene_switch_main_menu()
	else:
		menu -= 1
		host_button.visible = true
		join_button.visible = true
		ip_field.visible = false
		port_field.visible = false
		players_field.visible = false
		start_button.visible = false
		ip_entry.clear()
		port_entry.clear()


func _on_host_button_pressed() -> void:
	menu += 1
	hosting = true
	host_button.visible = false
	join_button.visible = false
	port_field.visible = true
	players_field.visible = true
	start_button.visible = true


func _on_join_button_pressed() -> void:
	menu += 1
	hosting = false
	host_button.visible = false
	join_button.visible = false
	ip_field.visible = true
	port_field.visible = true
	start_button.visible = true


func _on_start_button_pressed() -> void:
	if hosting:
		host_button_pressed.emit()
	else:
		connect_button_pressed.emit()
	queue_free()


func _on_h_slider_value_changed(value: float) -> void:
	$VBoxContainer/PlayersField/Label2.text = str(int(value))
