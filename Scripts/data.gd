extends Node

var characters: Array[HeroClass]
var cards: Array[Card]
var enemies: Array[Enemy]
var keymaps: Array[PlayerKeymap]
var mods: Dictionary[String, String]
var graphics: PlayerGraphicsSettings
var audio: PlayerAudioSettings
var preferences: PlayerPreferences
var player_profile: PlayerProfile
var player_keymap: PlayerKeymap
var player_controller_keymap: PlayerKeymap = preload("res://Resources/Keymaps/controller.tres")
var save_data: SaveData

const DEFAULT_SERVER_PORT: int = 58008

var wall_cost: int = 1
var printer_cost: int = 15
enum EnergyType {UNDEFINED = 0, DISCRETE = 1, CONTINUOUS = 2}
enum TargetType {UNDEFINED = 0, LAND = 1, AIR = 2, BOTH = 3}
enum EnemyType {UNDEFINED = 0, LAND = 1, AIR = 2}
enum Rarity {COMMON = 0, UNCOMMON = 1, RARE = 2, EPIC = 3, LEGENDARY = 4}
var rarity_weights: Dictionary = {
	"COMMON" = 50,
	"UNCOMMON" = 30,
	"RARE" = 10,
	"EPIC" = 4,
	"LEGENDARY" = 1
}


## Recursively searches a folder for any Card resources and loads them
func load_cards(path: String) -> void:
	cards = []
	var dir: DirAccess = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				load_cards(path + file_name)
			else:
				var card: Card = load(path + "/" + file_name)
				if card:
					cards.append(card)
			file_name = dir.get_next()


func load_classes() -> void:
	characters = []
	var dir: DirAccess = DirAccess.open("res://Classes")
	if dir:
		dir.list_dir_begin()
		var folder_name: String = dir.get_next()
		while folder_name != "":
			if dir.current_is_dir():
				var dir2: DirAccess = DirAccess.open("res://Classes/" + folder_name)
				if dir2:
					dir2.list_dir_begin()
					var folder_name2: String = dir2.get_next()
					while folder_name2 != "":
						if folder_name2 == "class.tres":
							var hero_class: HeroClass = load("res://Classes/" + folder_name + "/" + folder_name2)
							characters.append(hero_class)
						folder_name2 = dir2.get_next()
			else:
				pass
			folder_name = dir.get_next()


func load_mods(mod_list: Dictionary[String, bool]) -> void:
	for mod_name: String in mod_list:
		if mod_list[mod_name]:
			var success: bool = ProjectSettings.load_resource_pack(mods[mod_name])
			if success:
				print("Successfully loaded mod: " + mod_name + " at path: " + mods[mod_name])
			else:
				print("Failed to load mod: " + mod_name + " at path: " + mods[mod_name])
	load_classes()
	load_cards("res://Cards")

func _ready() -> void:
	var mod_dir: DirAccess = DirAccess.open("res://Mods")
	if mod_dir:
		mod_dir.list_dir_begin()
		var file_name: String = mod_dir.get_next()
		while file_name != "":
			if mod_dir.current_is_dir():
				var data_dir: DirAccess = DirAccess.open("res://Mods/" + file_name)
				if data_dir:
					data_dir.list_dir_begin()
					var data_name: String = data_dir.get_next()
					while data_name != "":
						if data_name.ends_with(".json"):
							var file: FileAccess = FileAccess.open("res://Mods/" + file_name + "/" + data_name, FileAccess.READ)
							var json_string: String = file.get_line()
							var json: JSON = JSON.new()
							var parse_result: Error = json.parse(json_string)
							if parse_result == OK:
								var dict: Dictionary = json.data
								mods[dict["display_name"]] = "res://Mods/" + file_name + "/" + dict["pck_path"]
						data_name = data_dir.get_next()
			file_name = mod_dir.get_next()

	keymaps.append(preload("res://Resources/Keymaps/qwerty.tres"))
	keymaps.append(preload("res://Resources/Keymaps/azerty.tres"))
	keymaps.append(preload("res://Resources/Keymaps/dvorak.tres"))
	keymaps.append(preload("res://Resources/Keymaps/colemak.tres"))
	keymaps.append(preload("res://Resources/Keymaps/workman.tres"))
	
	graphics = PlayerGraphicsSettings.load_profile_from_disk()
	graphics.apply_graphical_settings(get_viewport())
	audio = PlayerAudioSettings.load_profile_from_disk()
	audio.apply_audio_settings()
	player_profile = PlayerProfile.load_profile_from_disk()
	preferences = PlayerPreferences.load_profile_from_disk()
	player_keymap = PlayerKeymap.load_profile_from_disk()
	player_keymap.apply()
	player_controller_keymap.append_input_map()
	save_data = SaveData.load_profile_from_disk()
	
	load_classes()
	load_cards("res://Cards")
	
	enemies.append(preload("res://Resources/Enemies/dog.tres"))
	enemies.append(preload("res://Resources/Enemies/dog_fast.tres"))
	enemies.append(preload("res://Resources/Enemies/dog_heavy.tres"))
	enemies.append(preload("res://Resources/Enemies/dog_boss.tres"))
	enemies.append(preload("res://Resources/Enemies/airenemy.tres"))
	enemies.append(preload("res://Resources/Enemies/airenemy2.tres"))
	enemies.append(preload("res://Resources/Enemies/leapfrog.tres"))
