class_name PathingController extends EnemyMovement

var path: Curve3D
var path_progress: float = 0.0


func _ready() -> void:
	if path:
		distance_remaining = path.get_baked_length()


func _physics_process(delta: float) -> void:
	if !path:
		return
	var distance_travelled: float = (character.stats.movement_speed * clampf(character.movement_speed_penalty, 0.0, 1.0)) * delta
	distance_remaining -= distance_travelled
	path_progress += distance_travelled
	var sample: Transform3D = path.sample_baked_with_rotation(path_progress, true)
	character.global_position = sample.origin
	character.look_at(character.global_position + -sample.basis.z)
