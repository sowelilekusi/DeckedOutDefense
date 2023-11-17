extends Resource
class_name PlayerPreferences

const SAVE_PATH := "user://preferences.tres"

@export var mouse_sens := 28.0
@export var invert_lookY := false
@export var invert_lookX := false
@export var toggle_sprint := false
@export var fixed_minimap := false
@export var display_tower_damage_indicators := true
@export var display_self_damage_indicators := true
@export var display_party_damage_indicators := true
@export var display_status_effect_damage_indicators := true


func save_profile_to_disk():
	ResourceSaver.save(self, SAVE_PATH)
static func load_profile_from_disk() -> PlayerPreferences:
	if ResourceLoader.exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH)
	return PlayerPreferences.new()
