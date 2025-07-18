class_name Card3D
extends Node3D

@export var card_in_hand: CardInHand
@export var mesh: MeshInstance3D


func set_card(card: Card) -> void:
	card_in_hand.set_card(card)
	card_in_hand.view_tower()
	var material: ShaderMaterial = mesh.get_surface_override_material(1) as ShaderMaterial
	var gradient_tex: GradientTexture1D = material.get_shader_parameter("albedo") as GradientTexture1D
	gradient_tex.gradient.colors[0] = Data.rarity_colors[card.rarity]
