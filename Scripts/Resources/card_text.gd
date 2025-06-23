class_name CardText
extends Resource

@export var target_type: Data.TargetType
@export var energy_type: Data.EnergyType
@export var attributes: Array[StatAttribute]
@export_multiline var text: String


func get_attribute(attribute: String) -> float:
	for stat: StatAttribute in attributes:
		if stat.key == attribute:
			return stat.value
	return 0.0
