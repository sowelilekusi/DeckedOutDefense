class_name PricePanel
extends PanelContainer

@export var label: Label


func set_price(price: int) -> void:
	label.text = "$" + str(price)
