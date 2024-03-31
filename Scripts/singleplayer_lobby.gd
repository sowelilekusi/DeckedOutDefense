class_name SinglePlayerLobby extends Control

@export var scoreboard: Scoreboard
@export var loadout_editor: HeroSelector
@export var chatbox: Chatbox
@export var seed_entry: LineEdit
@export var ready_button: Button
@export var daily_button: Button

var connected_players_profiles: Dictionary = {}
var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()


func _ready() -> void:
	enet_peer.create_server(58008, 1)
	multiplayer.multiplayer_peer = enet_peer
	enet_peer.refuse_new_connections = true
	setup_game()


func setup_game() -> void:
	scoreboard.add_player(1, Data.player_profile)
	scoreboard.all_players_ready.connect(start_game)
	Game.game_setup.connect(setup_the_ui)
	Game.chatbox = chatbox
	chatbox.username = Data.player_profile.display_name
	Data.player_profile.display_name_changed.connect(chatbox.change_username)
	loadout_editor.hero_selected.connect(Data.player_profile.set_preferred_class)
	connected_players_profiles[1] = Data.player_profile
	Game.setup()


func start_game() -> void:
	scoreboard.set_visible(false)
	loadout_editor.set_visible(false)
	seed_entry.set_visible(false)
	daily_button.set_visible(false)
	ready_button.set_visible(false)
	Game.connected_player_profiles = connected_players_profiles
	var chosen_seed: int
	if seed_entry.text != "":
		if seed_entry.text.is_valid_int():
			chosen_seed = int(seed_entry.text)
		else:
			chosen_seed = hash(seed_entry.text)
		Game.start(chosen_seed)
	else:
		Game.start()


func setup_the_ui() -> void:
	scoreboard.unready_all_players()
	scoreboard.set_visible(true)
	loadout_editor.set_visible(true)
	$ReadyButton.set_visible(true)
	chatbox.set_visible(true)
	seed_entry.set_visible(true)
	daily_button.set_visible(true)
	ready_button.set_visible(true)


func _on_button_mouse_entered() -> void:
	$AudioStreamPlayer.play()


func _on_daily_button_pressed() -> void:
	scoreboard.set_visible(false)
	loadout_editor.set_visible(false)
	seed_entry.set_visible(false)
	daily_button.set_visible(false)
	ready_button.set_visible(false)
	Game.connected_player_profiles = connected_players_profiles
	Game.start(hash(Time.get_date_string_from_system(true)))
