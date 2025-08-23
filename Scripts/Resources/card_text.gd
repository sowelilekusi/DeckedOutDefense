class_name CardText
extends Resource

@export var target_type: Array[Data.TargetType]
@export var energy_type: Data.EnergyType
@export var attributes: Dictionary[String, float]
@export var features: Array[Feature]
@export_multiline var text: String


func get_attribute(attribute: String) -> float:
	if attributes.has(attribute):
		return attributes[attribute]
	return 0.0


func set_attribute(attribute: String, value: float) -> void:
	attributes[attribute] = value


func tower_features_applied() -> CardText:
	var card_text: CardText = self.duplicate()
	for feature: Feature in features:
		feature.attach_to_tower(card_text)
	return card_text


func weapon_features_applied() -> CardText:
	var card_text: CardText = self.duplicate()
	for feature: Feature in features:
		feature.attach_to_weapon(card_text)
	return card_text
