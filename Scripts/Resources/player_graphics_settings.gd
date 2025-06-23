class_name PlayerGraphicsSettings
extends Resource

const SAVE_PATH: String = "user://graphics_settings.tres"

@export var hfov: float = 100.0
@export var vsync_mode: int = 1
@export var aa_mode: int = 0
@export var windowed_mode: int = 0


func apply_graphical_settings(viewport: Viewport) -> void:
	#DisplayServer.window_set_vsync_mode(vsync_mode)
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


func save_profile_to_disk() -> void:
	ResourceSaver.save(self, SAVE_PATH)
static func load_profile_from_disk() -> PlayerGraphicsSettings:
	if ResourceLoader.exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH)
	return PlayerGraphicsSettings.new()
