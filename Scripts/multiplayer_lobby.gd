class_name MultiplayerLobby
extends Lobby

signal player_connected(peer_id: int, player_profile: PlayerProfile)
signal player_disconnected(peer_id: int)
signal disconnected_from_server

@export var server_form: ServerForm

var player_ready_boxes: Dictionary[PlayerProfile, CheckBox]
var player_character_selected_states: Dictionary[PlayerProfile, bool]

var alert_popup_scene: PackedScene = preload("res://Scenes/Menus/alert_popup.tscn")


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
	#setup_game(multiplayer.get_unique_id())
	connected_players_profiles[multiplayer.get_unique_id()] = Data.player_profile
	add_player_entry(Data.player_profile)
	$PanelContainer.visible = true


func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null
	var popup: AlertPopup = alert_popup_scene.instantiate() as AlertPopup
	popup.set_popup("Unable to connect to server", "OK")
	add_child(popup)


func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	disconnected_from_server.emit()


func create_server() -> void:
	enet_peer.create_server(server_form.port, server_form.max_players)
	multiplayer.multiplayer_peer = enet_peer
	add_player_entry(Data.player_profile)
	connected_players_profiles[1] = Data.player_profile
	$PanelContainer.visible = true
	#setup_game(1)


func setup_game() -> void:
	loadout_editor = character_select_screen.instantiate() as CharacterSelect
	add_child(loadout_editor)
	loadout_editor.hero_confirmed.connect(select_class)
	chatbox.username = Data.player_profile.display_name
	Data.player_profile.display_name_changed.connect(chatbox.change_username)
	for player: PlayerProfile in connected_players_profiles.values():
		player_character_selected_states[player] = false
	#loadout_editor.hero_selected.connect(Data.player_profile.set_preferred_class)
	#loadout_editor.hero_selected.connect(edit_player_profile)
	#player_connected.emit(peer_id, Data.player_profile)


func connect_to_server() -> void:
	enet_peer.create_client(server_form.ip, server_form.port)
	multiplayer.multiplayer_peer = enet_peer


@rpc("any_peer", "reliable")
func networked_ready_player(peer_id: int) -> void:
	player_ready_boxes[connected_players_profiles[peer_id]].button_pressed = true
	var start_game: bool = true
	for box: CheckBox in player_ready_boxes.values():
		if !box.button_pressed:
			start_game = false
	if start_game:
		setup_game()
		visible = false


func ready_player(peer_id: int = multiplayer.get_unique_id()) -> void:
	networked_ready_player.rpc(peer_id)
	$PanelContainer/VBoxContainer/ReadyButton.visible = false
	player_ready_boxes[connected_players_profiles[peer_id]].button_pressed = true
	var start_game: bool = true
	for box: CheckBox in player_ready_boxes.values():
		if !box.button_pressed:
			start_game = false
	if start_game:
		setup_game()
		visible = false


@rpc("any_peer", "reliable")
func networked_select_class(peer_id: int) -> void:
	player_character_selected_states[connected_players_profiles[peer_id]] = true
	if chatbox:
		chatbox.append_message("SERVER", Color.TOMATO, connected_players_profiles[peer_id].display_name + " has chosen a class!")
	var start_game: bool = true
	for state: bool in player_character_selected_states.values():
		if !state:
			start_game = false
	if start_game:
		start_game()


func select_class(peer_id: int = multiplayer.get_unique_id()) -> void:
	networked_select_class.rpc(peer_id)
	player_character_selected_states[connected_players_profiles[peer_id]] = true
	var start_game: bool = true
	for state: bool in player_character_selected_states.values():
		if !state:
			start_game = false
	if start_game:
		start_game()


func start_game() -> void:
	enet_peer.refuse_new_connections = true
	super.start_game()


func add_player_entry(profile: PlayerProfile) -> void:
	print("added player: " + str(profile.display_name))
	var entry: HBoxContainer = HBoxContainer.new()
	var label: Label = Label.new()
	var check: CheckBox = CheckBox.new()
	check.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = profile.display_name
	entry.add_child(label)
	entry.add_child(check)
	$PanelContainer/VBoxContainer.add_child(entry)
	player_ready_boxes[profile] = check


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
	add_player_entry(new_player_profile)
