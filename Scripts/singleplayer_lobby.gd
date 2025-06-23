class_name SinglePlayerLobby
extends Lobby


func _ready() -> void:
	enet_peer.create_server(Data.DEFAULT_SERVER_PORT, 1)
	multiplayer.multiplayer_peer = enet_peer
	enet_peer.refuse_new_connections = true


func setup_game() -> void:
	loadout_editor = character_select_screen.instantiate() as CharacterSelect
	loadout_editor.hero_confirmed.connect(start_game)
	add_child(loadout_editor)
	game_manager.chatbox = chatbox
	chatbox.username = Data.player_profile.display_name
	Data.player_profile.display_name_changed.connect(chatbox.change_username)
	loadout_editor.hero_selected.connect(Data.player_profile.set_preferred_class)
	connected_players_profiles[1] = Data.player_profile
	setup_the_ui()
