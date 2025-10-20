class_name FeatureUI
extends VBoxContainer

@export var icon: TextureRect
@export var name_label: Label

var feature: Feature


func set_feature(new_feature: Feature) -> void:
	feature = new_feature
	icon.texture = feature.icon
	name_label.text = tr(feature.display_name)
