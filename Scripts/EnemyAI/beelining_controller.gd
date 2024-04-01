class_name BeeliningController extends EnemyMovement

var goal: Node3D
var direction: Vector3


func _ready() -> void:
	distance_remaining = character.global_position.distance_to(goal.global_position)
	direction = character.global_position.direction_to(goal.global_position)


func _physics_process(delta: float) -> void:
	var distance_travelled: float = (character.stats.movement_speed * clampf(character.movement_speed_penalty, 0.0, 1.0)) * delta
	distance_remaining -= distance_travelled
	character.global_position = character.global_position + (direction * distance_travelled)
