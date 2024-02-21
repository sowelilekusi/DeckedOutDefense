class_name AlertPopup extends PanelContainer

signal completed()

func set_popup(prompt_text: String, dismiss_text: String) -> void:
	$VBoxContainer/Label.text = prompt_text
	$VBoxContainer/MarginContainerButton.text = dismiss_text


func _on_button_pressed() -> void:
	completed.emit()
	queue_free()


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()
