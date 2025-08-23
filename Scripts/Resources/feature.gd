class_name Feature
extends Resource

@export var display_name: String
@export var description: String
@export var icon: Texture2D
@export var strength: float


func attach_to_tower(tower_stats: CardText) -> void:
	pass


func attach_to_weapon(weapon_stats: CardText) -> void:
	pass
