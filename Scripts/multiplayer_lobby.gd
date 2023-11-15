extends Control
class_name MultiplayerLobby

signal player_connected(peer_id, player_profile)
signal player_disconnected(peer_id)
signal disconnected_from_server

const SERVER_PORT := 58008
const MAX_PLAYERS := 4

var enet_peer = ENetMultiplayerPeer.new()

@export var server_form : ServerForm
@export var scoreboard : Scoreboard
@export var loadout_editor : LoadoutEditor
@export var chatbox : Chatbox
var alert_popup_scene = preload("res://Scenes/Menus/alert_popup.tscn")
var connected_players_profiles = {}


func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connection_succeeded)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_player_connected(peer_id):
	add_player.rpc_id(peer_id, Data.player_profile.to_dict())


func _on_player_disconnected(peer_id):
	if chatbox:
		chatbox.append_message("SERVER", connected_players_profiles[peer_id].display_name + " has disconnected!")
	connected_players_profiles.erase(peer_id)
	player_disconnected.emit(peer_id)


func _on_connection_succeeded():
	setup_game(multiplayer.get_unique_id())


func _on_connection_failed():
	multiplayer.multiplayer_peer = null
	var popup = alert_popup_scene.instantiate() as AlertPopup
	popup.set_popup("Unable to connect to server", "OK")
	add_child(popup)


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	disconnected_from_server.emit()


func create_server() -> void:
	enet_peer.create_server(SERVER_PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = enet_peer
	setup_game(1)


func setup_game(peer_id):
	player_disconnected.connect(Game.remove_player)
	Game.spawn_level()
	scoreboard.all_players_ready.connect(start_game)
	Game.game_restarted.connect(setup_the_ui)
	setup_the_ui()
	chatbox.username = Data.player_profile.display_name
	Data.player_profile.display_name_changed.connect(chatbox.change_username)
	loadout_editor.character_selected.connect(Data.player_profile.set_preferred_class)
	loadout_editor.character_selected.connect(edit_player_profile)
	connected_players_profiles[peer_id] = Data.player_profile
	player_connected.emit(peer_id, Data.player_profile)


func setup_the_ui():
	scoreboard.unready_all_players()
	scoreboard.set_visible(true)
	loadout_editor.set_visible(true)
	$ReadyButton.set_visible(true)
	chatbox.set_visible(true)


func connect_to_server() -> void:
	var ip = server_form.get_server_ip() if server_form.get_server_ip() else "localhost"
	var port = server_form.get_server_port() if server_form.get_server_port() else str(SERVER_PORT)
	enet_peer.create_client(ip, int(port))
	multiplayer.multiplayer_peer = enet_peer


func ready_player():
	var peer_id = multiplayer.get_unique_id()
	networked_ready_player.rpc(peer_id)


func start_game():
	enet_peer.refuse_new_connections = true
	Game.spawn_players(connected_players_profiles.keys(), connected_players_profiles, chatbox.opened, chatbox.closed)
	scoreboard.set_visible(false)
	loadout_editor.set_visible(false)


func edit_player_profile(_argument):
	var profile_dict = Data.player_profile.to_dict()
	networked_edit_player_profile.rpc(multiplayer.get_unique_id(), profile_dict)


@rpc("any_peer", "reliable", "call_local")
func networked_edit_player_profile(peer_id, new_profile_dict):
	connected_players_profiles[peer_id].set_display_name(new_profile_dict["display_name"])
	connected_players_profiles[peer_id].set_preferred_class(new_profile_dict["preferred_class"])


@rpc("any_peer","reliable")
func add_player(new_player_profile_dict):
	var new_player_peer_id = multiplayer.get_remote_sender_id()
	var new_player_profile = PlayerProfile.from_dict(new_player_profile_dict)
	if chatbox:
		chatbox.append_message("SERVER", new_player_profile.display_name + " has connected!")
	connected_players_profiles[new_player_peer_id] = new_player_profile
	player_connected.emit(new_player_peer_id, new_player_profile)


@rpc("any_peer", "reliable", "call_local")
func networked_ready_player(peer_id):
	scoreboard.set_player_ready_state(peer_id, true)
