class_name MultiplayerLobby extends Control

signal player_connected(peer_id: int, player_profile: PlayerProfile)
signal player_disconnected(peer_id: int)
signal disconnected_from_server

const SERVER_PORT: int = 58008
const MAX_PLAYERS: int = 4

@export var server_form: ServerForm
@export var scoreboard: Scoreboard
@export var loadout_editor: HeroSelector
@export var chatbox: Chatbox

var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var alert_popup_scene: PackedScene = preload("res://Scenes/Menus/alert_popup.tscn")
var connected_players_profiles: Dictionary = {}


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connection_succeeded)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_player_connected(peer_id: int) -> void:
	add_player.rpc_id(peer_id, Data.player_profile.to_dict())


func _on_player_disconnected(peer_id: int) -> void:
	if chatbox:
		chatbox.append_message("SERVER", Color.TOMATO, connected_players_profiles[peer_id].display_name + " has disconnected!")
	connected_players_profiles.erase(peer_id)
	player_disconnected.emit(peer_id)


func _on_connection_succeeded() -> void:
	setup_game(multiplayer.get_unique_id())


func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null
	var popup: AlertPopup = alert_popup_scene.instantiate() as AlertPopup
	popup.set_popup("Unable to connect to server", "OK")
	add_child(popup)


func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	disconnected_from_server.emit()


func create_server() -> void:
	enet_peer.create_server(SERVER_PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = enet_peer
	setup_game(1)


func setup_game(peer_id: int) -> void:
	player_disconnected.connect(Game.remove_player)
	scoreboard.all_players_ready.connect(start_game)
	Game.game_setup.connect(setup_the_ui)
	Game.chatbox = chatbox
	chatbox.username = Data.player_profile.display_name
	Data.player_profile.display_name_changed.connect(chatbox.change_username)
	loadout_editor.hero_selected.connect(Data.player_profile.set_preferred_class)
	loadout_editor.hero_selected.connect(edit_player_profile)
	connected_players_profiles[peer_id] = Data.player_profile
	player_connected.emit(peer_id, Data.player_profile)
	Game.setup()


func setup_the_ui() -> void:
	scoreboard.unready_all_players()
	scoreboard.set_visible(true)
	loadout_editor.set_visible(true)
	$ReadyButton.set_visible(true)
	chatbox.set_visible(true)


func connect_to_server() -> void:
	var ip: String = server_form.get_server_ip() if server_form.get_server_ip() else "localhost"
	var port: String = server_form.get_server_port() if server_form.get_server_port() else str(SERVER_PORT)
	enet_peer.create_client(ip, int(port))
	multiplayer.multiplayer_peer = enet_peer


func ready_player() -> void:
	var peer_id: int = multiplayer.get_unique_id()
	networked_ready_player.rpc(peer_id)


func start_game() -> void:
	enet_peer.refuse_new_connections = true
	scoreboard.set_visible(false)
	loadout_editor.set_visible(false)
	Game.connected_player_profiles = connected_players_profiles
	Game.start()


#TODO: what the fuck is this doing lol
func edit_player_profile(_argument: int) -> void:
	var profile_dict: Dictionary = Data.player_profile.to_dict()
	networked_edit_player_profile.rpc(multiplayer.get_unique_id(), profile_dict)


@rpc("any_peer", "reliable", "call_local")
func networked_edit_player_profile(peer_id: int, new_profile_dict: Dictionary) -> void:
	connected_players_profiles[peer_id].set_display_name(new_profile_dict["display_name"])
	connected_players_profiles[peer_id].set_preferred_class(new_profile_dict["preferred_class"])


@rpc("any_peer","reliable")
func add_player(new_player_profile_dict: Dictionary) -> void:
	var new_player_peer_id: int = multiplayer.get_remote_sender_id()
	var new_player_profile: PlayerProfile = PlayerProfile.from_dict(new_player_profile_dict)
	if chatbox:
		chatbox.append_message("SERVER", Color.TOMATO, new_player_profile.display_name + " has connected!")
	connected_players_profiles[new_player_peer_id] = new_player_profile
	player_connected.emit(new_player_peer_id, new_player_profile)


@rpc("any_peer", "reliable", "call_local")
func networked_ready_player(peer_id: int) -> void:
	scoreboard.set_player_ready_state(peer_id, true)


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()
