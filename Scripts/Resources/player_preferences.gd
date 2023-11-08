extends Resource
class_name PlayerPreferences

const SAVE_PATH := "user://preferences.tres"

@export var mouse_sens := 28.0
@export var invert_lookY := false
@export var invert_lookX := false
@export var toggle_sprint := false
@export var vsync_mode := 1
@export var aa_mode := 0
@export var windowed_mode := 0
@export var hfov := 100.0


func apply_graphical_settings(viewport):
	DisplayServer.window_set_vsync_mode(vsync_mode)
	match aa_mode:
		0:
			viewport.use_taa = false
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		1:
			viewport.use_taa = false
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		2:
			viewport.use_taa = true
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	match windowed_mode:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


func save_profile_to_disk():
	ResourceSaver.save(self, SAVE_PATH)
static func load_profile_from_disk() -> PlayerPreferences:
	if ResourceLoader.exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH)
	return PlayerPreferences.new()
