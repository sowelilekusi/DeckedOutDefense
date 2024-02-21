class_name TextInputPopup extends PanelContainer

signal completed(outcome: bool)


func set_popup(prompt_text: String, placeholder_text: String, confirm_text: String) -> void:
	$VBoxContainer/LineEdit.text = prompt_text
	$VBoxContainer/LineEdit.placeholder_text = placeholder_text
	$VBoxContainer/Button.text = confirm_text


func _on_button_pressed() -> void:
	completed.emit($VBoxContainer/LineEdit.text)
	queue_free()


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()
