class_name CardItem
extends InteractButton

signal pressed(card_item: CardItem)

@export var outline_mesh: MeshInstance3D
@export var card_ui: CardInHand
var card: Card = null
var rarity_colors: Array[Color] = [
	Color8(255, 255, 255),
	Color8(50, 204, 36),
	Color8(36, 59, 204),
	Color8(181, 36, 204),
	Color8(225, 112, 30)
]


func set_card(new_card: Card) -> void:
	card = new_card
	card_ui.set_card(card)
	card_ui.view_tower()
	outline_mesh.get_surface_override_material(0).albedo_color = rarity_colors[card.rarity]
	#print(rarity_colors[card.rarity])


func press(callback_player: Hero) -> void:
	pressed.emit(self)


func enable_hover_effect() -> void:
	$Sprite3D.visible = true


func disable_hover_effect() -> void:
	$Sprite3D.visible = false
