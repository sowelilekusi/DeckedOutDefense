extends StaticBody3D
class_name ItemCard

@export var card : Card


func pick_up() -> Card:
	queue_free()
	networked_pick_up.rpc()
	return card


@rpc func networked_pick_up():
	queue_free()
