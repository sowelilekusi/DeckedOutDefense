extends Control
class_name Chatbox

signal opened
signal closed

@export var input_line : LineEdit
@export var textbox : RichTextLabel
@export var text_panel : PanelContainer
@export var fade_timer : Timer

var text_selected := false
var username := "default"
var color = Color.TOMATO
var fading = true
var time_to_fade = 2.0
var time_since_started_fading = 2.0


func _process(delta: float) -> void:
	if fading:
		time_since_started_fading += delta
	else:
		time_since_started_fading = 0.0
	textbox.modulate.a = lerpf(1.0, 0.0, time_since_started_fading / time_to_fade)
	text_panel.modulate.a = lerpf(1.0, 0.0, time_since_started_fading / time_to_fade)


func _input(event: InputEvent) -> void:
	if !text_selected and event.is_action_pressed("Open Text Chat"):
		get_viewport().set_input_as_handled()
		opened.emit()
		input_line.visible = true
		input_line.grab_focus()
		text_selected = true
		fading = false
		return
	if text_selected and event is InputEventKey and event.pressed == true:
		if event.keycode == KEY_ENTER:
			get_viewport().set_input_as_handled()
			closed.emit()
			input_line.deselect()
			input_line.visible = false
			text_selected = false
			if input_line.text.length() != 0:
				if input_line.text.begins_with("/"):
					Game.parse_command(input_line.text, multiplayer.get_unique_id())
					fade_timer.start()
				else:
					append_message.rpc(username, color, input_line.text)
			input_line.clear()
		if event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			closed.emit()
			input_line.deselect()
			input_line.visible = false
			text_selected = false
			fade_timer.start()


func change_username(old_name, new_name):
	append_message("SERVER", Color.TOMATO, old_name + " has changed their display name to " + new_name)


@rpc("reliable","call_local","any_peer")
func append_message(user, user_color, content):
	textbox.append_text("[[color=" + user_color.to_html() + "]" + user + "[color=white]] " + content + "\n")
	fading = false
	fade_timer.start()


func _on_timer_timeout() -> void:
	fading = true
