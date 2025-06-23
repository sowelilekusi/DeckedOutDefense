class_name TowerLabel
extends HBoxContainer

@export var tower_name: Label
@export var tower_amount: Label


func change_label(new_name: String, new_amount: String) -> void:
	tower_name.text = new_name
	tower_amount.text = new_amount
