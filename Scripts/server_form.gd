class_name ServerForm extends PanelContainer

signal connect_button_pressed
signal host_button_pressed


func _on_host_pressed() -> void:
	host_button_pressed.emit()
	queue_free()
func _on_connect_pressed() -> void:
	connect_button_pressed.emit()
	queue_free()

func get_server_ip() -> String:
	return $VBoxContainer/HBoxContainer/ServerIP.text
func get_server_port() -> String:
	return $VBoxContainer/HBoxContainer2/ServerPort.text


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()


func _on_button_pressed() -> void:
	Game.scene_switch_main_menu()
