class_name PlayerProfile extends Resource

signal display_name_changed(old_name: String, new_name: String)
signal preferred_class_changed(old_class: int, new_class: int)

const SAVE_PATH: String = "user://profile.tres"

@export var display_name: String = "Charlie"
@export var preferred_class: int = 0

func to_dict() -> Dictionary:
	var dict: Dictionary = {}
	dict["display_name"] = display_name
	dict["preferred_class"] = preferred_class
	return dict
static func from_dict(dict: Dictionary) -> PlayerProfile:
	var output: PlayerProfile = PlayerProfile.new()
	output.display_name = dict["display_name"]
	output.preferred_class = dict["preferred_class"]
	return output

func set_display_name(new_display_name: String) -> void:
	if new_display_name == display_name:
		return
	var old_name: String = display_name
	display_name = new_display_name
	save_profile_to_disk()
	display_name_changed.emit(old_name, display_name)
func get_display_name() -> String:
	return display_name

func set_preferred_class(new_preferred_class: int) -> void:
	if new_preferred_class == preferred_class:
		return
	var old_class: int = preferred_class
	preferred_class = new_preferred_class
	preferred_class_changed.emit(old_class, preferred_class)
func get_preferred_class() -> int:
	return preferred_class

func save_profile_to_disk() -> void:
	ResourceSaver.save(self, SAVE_PATH)
static func load_profile_from_disk() -> PlayerProfile:
	if ResourceLoader.exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH)
	return PlayerProfile.new()
