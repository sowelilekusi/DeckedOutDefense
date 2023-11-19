extends PanelContainer
class_name ConfirmationPopup

signal completed(outcome)

func set_popup(prompt_text, confirm_text, cancel_text):
	$VBoxContainer/Label.text = prompt_text
	$VBoxContainer/HBoxContainer/MarginContainer/Confirm.text = confirm_text
	$VBoxContainer/HBoxContainer/MarginContainer2/Cancel.text = cancel_text


func _on_confirm_pressed() -> void:
	completed.emit(true)
	queue_free()


func _on_cancel_pressed() -> void:
	completed.emit(false)
	queue_free()
