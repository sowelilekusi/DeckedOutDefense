extends Node

var characters: Array[HeroClass]
var cards: Array[Card]
var enemies: Array[Enemy]
var keymaps: Array[PlayerKeymap]
var graphics: PlayerGraphicsSettings
var audio: PlayerAudioSettings
var preferences: PlayerPreferences
var player_profile: PlayerProfile
var player_keymap: PlayerKeymap
var player_controller_keymap: PlayerKeymap = preload("res://Resources/Keymaps/controller.tres")
var save_stats: SaveStats

var wall_cost: int = 1
var printer_cost: int = 15
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

func _ready() -> void:
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
	save_stats = SaveStats.load_profile_from_disk()
	
	characters.append(preload("res://PCs/Mechanic/red.tres"))
	#characters.append(preload("res://PCs/Green/green.tres"))
	characters.append(preload("res://PCs/Mage/blue.tres"))
	
	#Common
	cards.append(preload("res://PCs/Mechanic/ClassCards/Assault/card_assault.tres"))
	cards.append(preload("res://PCs/Mechanic/ClassCards/BombLauncher/card_bomb_launcher.tres"))
	cards.append(preload("res://PCs/Mechanic/ClassCards/Gatling/card_gatling.tres"))
	cards.append(preload("res://PCs/Mechanic/ClassCards/RocketLauncher/card_rocket_launcher.tres"))
	#Uncommon
	cards.append(preload("res://PCs/Mechanic/ClassCards/Sniper/card_sniper.tres"))
	cards.append(preload("res://PCs/Entomologist/ClassCards/Blowdart/card_blowdart.tres"))
	cards.append(preload("res://PCs/Mage/ClassCards/Refrigerator/card_refrigerator.tres"))
	cards.append(preload("res://PCs/Mechanic/ClassCards/GlueLauncher/card_glue_launcher.tres"))
	#Rare
	cards.append(preload("res://PCs/Mechanic/ClassCards/Flamethrower/card_flamethrower.tres"))
	#cards.append(preload("res://PCs/Universal/ClassCards/DamageEnhancer/card_damage_enhancer.tres"))
	#cards.append(preload("res://PCs/Universal/ClassCards/SpeedEnhancer/card_speed_enhancer.tres"))
	#Epic
	cards.append(preload("res://PCs/Mage/ClassCards/Icicle/card_icicle.tres"))
	cards.append(preload("res://PCs/Mage/ClassCards/Fireball/card_fireball.tres"))
	#cards.append(preload("res://PCs/Universal/ClassCards/GammaLaser/card_gamma_laser.tres"))
	#Legendary
	cards.append(preload("res://PCs/Mechanic/ClassCards/Reactor/card_reactor.tres"))
	#cards.append(preload("res://PCs/Universal/ClassCards/Lightning/card_lightning.tres"))
	
	enemies.append(preload("res://Worlds/GreenPlanet/Enemies/dog.tres"))
	enemies.append(preload("res://Worlds/GreenPlanet/Enemies/dog_fast.tres"))
	enemies.append(preload("res://Worlds/GreenPlanet/Enemies/dog_heavy.tres"))
	enemies.append(preload("res://Worlds/GreenPlanet/Enemies/dog_boss.tres"))
	enemies.append(preload("res://Worlds/GreenPlanet/Enemies/airenemy.tres"))
	enemies.append(preload("res://Worlds/GreenPlanet/Enemies/airenemy2.tres"))
