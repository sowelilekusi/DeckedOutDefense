class_name PlayerPreferences extends Resource

const SAVE_PATH: String = "user://preferences.tres"

@export var mouse_sens: float = 28.0
@export var invert_lookY: bool = false
@export var invert_lookX: bool = false
@export var toggle_sprint: bool = false
@export var fixed_minimap: bool = false
@export var display_tower_damage_indicators: bool = true
@export var display_self_damage_indicators: bool = true
@export var display_party_damage_indicators: bool = true
@export var display_status_effect_damage_indicators: bool = true


func save_profile_to_disk() -> void:
	ResourceSaver.save(self, SAVE_PATH)
static func load_profile_from_disk() -> PlayerPreferences:
	if ResourceLoader.exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH)
	return PlayerPreferences.new()
