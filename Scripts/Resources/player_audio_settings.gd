class_name PlayerAudioSettings
extends Resource

const SAVE_PATH: String = "user://audio_settings.tres"

@export var master: float = 100.0
@export var music: float = 100.0
@export var sfx: float = 100.0


func apply_audio_settings() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master / 100.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music / 100.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx / 100.0))


func save_profile_to_disk() -> void:
	ResourceSaver.save(self, SAVE_PATH)
static func load_profile_from_disk() -> PlayerAudioSettings:
	if ResourceLoader.exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH)
	return PlayerAudioSettings.new()
