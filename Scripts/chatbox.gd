extends Control
class_name Chatbox

signal opened
signal closed

var text_selected := false
var username := "default"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Open Text Chat"):
		if text_selected:
			closed.emit()
			$VBoxContainer/LineEdit.deselect()
			$VBoxContainer/LineEdit.visible = false
			text_selected = false
			if $VBoxContainer/LineEdit.text.length() != 0:
				if $VBoxContainer/LineEdit.text.begins_with("/"):
					Game.parse_command($VBoxContainer/LineEdit.text, multiplayer.get_unique_id())
				else:
					rpc("append_message", username, $VBoxContainer/LineEdit.text)
			$VBoxContainer/LineEdit.clear()
		else:
			opened.emit()
			$VBoxContainer/LineEdit.visible = true
			$VBoxContainer/LineEdit.grab_focus()
			text_selected = true


func change_username(old_name, new_name):
	append_message("server", old_name + " has changed their display name to " + new_name)


@rpc("reliable","call_local","any_peer")
func append_message(user, content):
	$VBoxContainer/RichTextLabel.append_text("[" + user + "] " + content + "\n")
