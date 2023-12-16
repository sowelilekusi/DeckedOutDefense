extends Resource
class_name SaveStats

const SAVE_PATH := "user://save_stats.tres"

@export var wins: int
@export var losses: int
@export var twenty_game_history: Array[bool]


func add_game_outcome(outcome: bool) -> void:
	if outcome:
		wins += 1
	else:
		losses += 1
	twenty_game_history.push_back(outcome)
	if twenty_game_history.size() > 20:
		twenty_game_history.pop_front()


func save_profile_to_disk():
	ResourceSaver.save(self, SAVE_PATH)
static func load_profile_from_disk() -> SaveStats:
	if ResourceLoader.exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH)
	return SaveStats.new()
