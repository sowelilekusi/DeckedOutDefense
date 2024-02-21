class_name SinglePlayerLobby extends Control

@export var scoreboard: Scoreboard
@export var loadout_editor: HeroSelector
@export var chatbox: Chatbox

var connected_players_profiles: Dictionary = {}
var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()


func _ready() -> void:
	enet_peer.create_server(58008, 1)
	multiplayer.multiplayer_peer = enet_peer
	enet_peer.refuse_new_connections = true
	setup_game()


func setup_game() -> void:
	Game.spawn_level()
	scoreboard.add_player(1, Data.player_profile)
	scoreboard.all_players_ready.connect(start_game)
	Game.game_restarted.connect(setup_the_ui)
	Game.chatbox = chatbox
	setup_the_ui()
	chatbox.username = Data.player_profile.display_name
	Data.player_profile.display_name_changed.connect(chatbox.change_username)
	loadout_editor.hero_selected.connect(Data.player_profile.set_preferred_class)
	connected_players_profiles[1] = Data.player_profile


func start_game() -> void:
	Game.spawn_players(connected_players_profiles.keys(), connected_players_profiles, chatbox.opened, chatbox.closed)
	scoreboard.set_visible(false)
	loadout_editor.set_visible(false)


func setup_the_ui() -> void:
	scoreboard.unready_all_players()
	scoreboard.set_visible(true)
	loadout_editor.set_visible(true)
	$ReadyButton.set_visible(true)
	chatbox.set_visible(true)


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()
