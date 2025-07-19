class_name CardItem
extends InteractButton

signal pressed(card_item: CardItem)

@export var outline_mesh: MeshInstance3D
@export var card_ui: CardInHand
var card: Card = null



func set_card(new_card: Card) -> void:
	card = new_card
	card_ui.set_card(card)
	card_ui.view_tower()
	outline_mesh.get_surface_override_material(0).albedo_color = Data.rarity_colors[card.rarity]
	#print(rarity_colors[card.rarity])


func press(_callback_player: Hero) -> void:
	pressed.emit(self)


func enable_hover_effect() -> void:
	$Sprite3D.visible = true


func disable_hover_effect() -> void:
	$Sprite3D.visible = false
