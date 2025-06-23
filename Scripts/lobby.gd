class_name Lobby
extends Control

@export var character_select_screen: PackedScene
#@export var scoreboard: Scoreboard
@export var chatbox: Chatbox
#@export var ready_button: Button
@export var audio_player: AudioStreamPlayer

var game_manager: GameManager
var gamemode: GameMode = null
var loadout_editor: CharacterSelect = null
var connected_players_profiles: Dictionary = {}
var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func setup_the_ui() -> void:
	#scoreboard.unready_all_players()
	#scoreboard.set_visible(true)
	loadout_editor.set_visible(true)
	chatbox.set_visible(true)
	chatbox.game_manager = game_manager
	#ready_button.set_visible(true)


func start_game() -> void:
	game_manager.setup()
	#scoreboard.set_visible(false)
	loadout_editor.queue_free()
	#ready_button.set_visible(false)
	game_manager.connected_player_profiles = connected_players_profiles
	game_manager.start()


func _on_button_mouse_entered() -> void:
	audio_player.play()
