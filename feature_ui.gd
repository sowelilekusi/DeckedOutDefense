class_name FeatureUI
extends VBoxContainer

@export var icon: TextureRect
@export var name_label: Label


func set_feature(feature: Feature) -> void:
	icon.texture = feature.icon
	name_label.text = tr(feature.display_name)
