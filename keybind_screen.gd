extends Control

signal event_detected(event: InputEvent)

var found_event: bool = false

func _input(event: InputEvent) -> void:
	if found_event:
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		get_viewport().set_input_as_handled()
		found_event = true
		event_detected.emit(event)
		queue_free()
		
