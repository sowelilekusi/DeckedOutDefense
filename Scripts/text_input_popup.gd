extends PanelContainer
class_name TextInputPopup

signal completed(outcome)

func set_popup(prompt_text, placeholder_text, confirm_text):
	$VBoxContainer/LineEdit.text = prompt_text
	$VBoxContainer/LineEdit.placeholder_text = placeholder_text
	$VBoxContainer/Button.text = confirm_text


func _on_button_pressed() -> void:
	completed.emit($VBoxContainer/LineEdit.text)
	queue_free()
