class_name ConfirmationPopup
extends PanelContainer

signal completed(outcome: bool)

func set_popup(prompt_text: String, confirm_text: String, cancel_text: String) -> void:
	$VBoxContainer/Label.text = prompt_text
	$VBoxContainer/HBoxContainer/Confirm.text = confirm_text
	$VBoxContainer/HBoxContainer/Cancel.text = cancel_text


func _on_confirm_pressed() -> void:
	completed.emit(true)
	queue_free()


func _on_cancel_pressed() -> void:
	completed.emit(false)
	queue_free()


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()
