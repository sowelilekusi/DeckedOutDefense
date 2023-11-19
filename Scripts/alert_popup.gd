extends PanelContainer
class_name AlertPopup

signal completed

func set_popup(prompt_text, dismiss_text):
	$VBoxContainer/Label.text = prompt_text
	$VBoxContainer/MarginContainerButton.text = dismiss_text


func _on_button_pressed() -> void:
	completed.emit()
	queue_free()
