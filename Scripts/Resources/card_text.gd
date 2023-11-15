extends Resource
class_name CardText

@export var target_type : Data.TargetType
@export var attributes : Array[StatAttribute]
@export_multiline var text : String


func get_attribute(attribute : String) -> float:
	for stat in attributes:
		if stat.key == attribute:
			return stat.value
	return 0.0
