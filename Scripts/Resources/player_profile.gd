extends Resource
class_name PlayerProfile

signal display_name_changed(old_name, new_name)
signal preferred_class_changed(old_class, new_class)

const SAVE_PATH := "user://profile.tres"

@export var display_name := "Charlie"
@export var preferred_class := 0

func to_dict() -> Dictionary:
	var dict = {}
	dict["display_name"] = display_name
	dict["preferred_class"] = preferred_class
	return dict
static func from_dict(dict) -> PlayerProfile:
	var output = PlayerProfile.new()
	output.display_name = dict["display_name"]
	output.preferred_class = dict["preferred_class"]
	return output

func set_display_name(new_display_name):
	if new_display_name == display_name:
		return
	var old_name = display_name
	display_name = new_display_name
	save_profile_to_disk()
	display_name_changed.emit(old_name, display_name)
func get_display_name() -> String:
	return display_name

func set_preferred_class(new_preferred_class):
	if new_preferred_class == preferred_class:
		return
	var old_class = preferred_class
	preferred_class = new_preferred_class
	preferred_class_changed.emit(old_class, preferred_class)
func get_preferred_class() -> int:
	return preferred_class

func save_profile_to_disk():
	ResourceSaver.save(self, SAVE_PATH)
static func load_profile_from_disk() -> PlayerProfile:
	if ResourceLoader.exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH)
	return PlayerProfile.new()
