extends Node

var characters : Array[HeroClass]
var cards : Array[Card]
var enemies : Array[Enemy]
var keymaps : Array[PlayerKeymap]
var preferences : PlayerPreferences
var player_profile : PlayerProfile
var player_keymap : PlayerKeymap

var wall_cost := 4
var printer_cost := 10
enum TargetType {LAND = 1, AIR = 2, BOTH = 3}
enum EnemyType {LAND = 1, AIR = 2}
enum Rarity {COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}
var rarity_weights = {
	"COMMON" = 100,
	"UNCOMMON" = 60,
	"RARE" = 20,
	"EPIC" = 8,
	"LEGENDARY" = 1
}

func _ready() -> void:
	player_profile = PlayerProfile.load_profile_from_disk()
	preferences = PlayerPreferences.load_profile_from_disk()
	player_keymap = PlayerKeymap.load_profile_from_disk()
	preferences.apply_graphical_settings(get_viewport())
	player_keymap.apply()
	
	characters.append(preload("res://PCs/Red/red.tres"))
	characters.append(preload("res://PCs/Green/green.tres"))
	characters.append(preload("res://PCs/Blue/blue.tres"))
	
	cards.append(preload("res://PCs/Universal/ClassCards/Assault/card_assault.tres"))
	cards.append(preload("res://PCs/Universal/ClassCards/BombLauncher/card_grenade_launcher.tres"))
	cards.append(preload("res://PCs/Universal/ClassCards/Sniper/card_sniper.tres"))
	cards.append(preload("res://PCs/Universal/ClassCards/Gatling/card_gatling.tres"))
	cards.append(preload("res://PCs/Universal/ClassCards/GlueLauncher/card_glue_launcher.tres"))
	cards.append(preload("res://PCs/Universal/ClassCards/RocketLauncher/card_rocket_launcher.tres"))
	
	enemies.append(preload("res://Worlds/GreenPlanet/Enemies/dog.tres"))
	enemies.append(preload("res://Worlds/GreenPlanet/Enemies/dog_fast.tres"))
	enemies.append(preload("res://Worlds/GreenPlanet/Enemies/dog_heavy.tres"))
	enemies.append(preload("res://Worlds/GreenPlanet/Enemies/dog_boss.tres"))
	enemies.append(preload("res://Worlds/GreenPlanet/Enemies/airenemy.tres"))
	enemies.append(preload("res://Worlds/GreenPlanet/Enemies/airenemy2.tres"))
	
	keymaps.append(preload("res://Resources/Keymaps/qwerty.tres"))
	keymaps.append(preload("res://Resources/Keymaps/azerty.tres"))
	keymaps.append(preload("res://Resources/Keymaps/dvorak.tres"))
	keymaps.append(preload("res://Resources/Keymaps/colemak.tres"))
	keymaps.append(preload("res://Resources/Keymaps/workman.tres"))
