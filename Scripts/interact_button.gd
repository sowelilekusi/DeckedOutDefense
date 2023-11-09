extends StaticBody3D
class_name InteractButton

signal button_interacted(value)

@export var button_press_value := 0
@export var press_cost := 0
@export var hover_text := "Press [Interact]"

func press():
	button_interacted.emit(button_press_value)
