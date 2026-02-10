class_name Lobby
extends Control

@export var character_select_screen: PackedScene
@export var chatbox: Chatbox
@export var audio_player: AudioStreamPlayer
@export var chatbox_scene: PackedScene

var game_manager: GameManager
var gamemode: GameMode = null
var loadout_editor: CharacterSelect = null
var connected_players_profiles: Dictionary = {}
var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()


func setup_the_ui() -> void:
	chatbox = chatbox_scene.instantiate()
	game_manager.UILayer.add_child(chatbox)
	chatbox.set_visible(true)
	chatbox.game_manager = game_manager
	game_manager.chatbox = chatbox
	chatbox.anchor_bottom = 0.98
	chatbox.anchor_left = 0.02
	chatbox.anchor_top = 0.7
	chatbox.anchor_right = 0.4


func start_game() -> void:
	game_manager.setup()
	loadout_editor.queue_free()
	game_manager.connected_player_profiles = connected_players_profiles
	game_manager.start()


func _on_button_mouse_entered() -> void:
	audio_player.play()
