class_name InteractButton extends StaticBody3D

signal button_interacted(value: int, callback: Hero)

@export var button_press_value: int = 0
@export var press_cost: int = 0
@export var hover_text: String = "Press [Interact]"


func press(callback_player: Hero) -> void:
	button_interacted.emit(button_press_value, callback_player)
