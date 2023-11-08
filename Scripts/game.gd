extends Node

signal wave_started(wave_number)
signal wave_finished(wave_number)
signal base_took_damage(remaining_health)
signal game_started
signal game_restarted
signal lost_game
signal won_game
signal enemy_number_changed(number_of_enemies)

var level_scene = load("res://Worlds/GreenPlanet/Levels/first_level.tscn")
var player_scene = load("res://PCs/hero.tscn")
var main_menu_scene_path = "res://Scenes/Menus/main_menu.tscn"
var multiplayer_lobby_scene_path = "res://Scenes/Menus/multiplayer_lobby.tscn"
var singleplayer_lobby_scene_path = "res://Scenes/Menus/singleplayer_lobby.tscn"
var won_game_scene = load("res://Scenes/Menus/won_game_screen.tscn")
var lose_game_scene = load("res://Scenes/Menus/lost_game_screen.tscn")
var connected_players_nodes = {}
var game_active := false
var level : Level
var enemies := 0
var objective_health := 120
var wave := 0
var upcoming_wave
var pot : int


func parse_command(text : String, peer_id : int):
	if text.substr(1, 4) == "give":
		var gift_name = text.substr(6) as String
		var gift = Data.cards[0]
		for x in Data.cards:
			if x.title == gift_name:
				gift = x
		connected_players_nodes[peer_id].inventory.add(gift)


func spawn_level():
	level = level_scene.instantiate() as Level
	for x in level.enemy_spawns:
		#x.path = level.a_star_graph_3d.visualized_path
		x.signal_for_after_enemy_died = enemy_died
		x.signal_for_after_enemy_reached_goal = damage_goal
		x.signal_for_when_enemy_spawns.connect(increase_enemy_count)
	add_child(level)


func spawn_players(player_array, player_profiles, chatbox_open_signal, chatbox_closed_signal):
	var p_i = 0
	player_array.sort()
	for peer_id in player_array:
		var player = player_scene.instantiate() as Hero
		player.name = str(peer_id)
		player.position = level.player_spawns[p_i].global_position
		player.profile = player_profiles[peer_id]
		player.hero_class = Data.characters[player_profiles[peer_id].preferred_class]
		player.ready_state_changed.connect(ready_player)
		if peer_id == multiplayer.get_unique_id():
			chatbox_open_signal.connect(player.pause)
			chatbox_closed_signal.connect(player.unpause)
		player.set_multiplayer_authority(peer_id)
		connected_players_nodes[peer_id] = player
		wave_started.connect(player.exit_editing_mode)
		wave_finished.connect(player.enter_editing_mode)
		base_took_damage.connect(player.hud.set_lives_count)
		enemy_number_changed.connect(player.hud.set_enemy_count)
		add_child(player)
		p_i += 1
	start_game()


func ready_player(_value):
	for key in connected_players_nodes:
		if connected_players_nodes[key].ready_state == false:
			return
	for key in connected_players_nodes:
		connected_players_nodes[key].ready_state = false
	spawn_enemy_wave()


func spawn_enemy_wave():
	wave += 1
	level.a_star_graph_3d.find_path()
	level.a_star_graph_3d.visualized_path.disable_visualization()
	for spawn in level.enemy_spawns:
		spawn.spawn_wave(upcoming_wave)
	wave_started.emit(wave)


func set_upcoming_wave():
	var spawn_power = WaveManager.calculate_spawn_power(wave + 1, connected_players_nodes.size())
	upcoming_wave = WaveManager.generate_wave(spawn_power, level.enemy_pool)
	pot = 6 + (spawn_power / 100)


func increase_enemy_count():
	enemies += 1
	enemy_number_changed.emit(enemies)


func enemy_died():
	enemies -= 1
	enemy_number_changed.emit(enemies)
	for x in level.enemy_spawns:
		if !x.done_spawning:
			return
	if enemies == 0:
		end_wave()
		if wave >= 20:
			win_game()


func damage_goal(penalty):
	enemies -= 1
	enemy_number_changed.emit(enemies)
	objective_health -= penalty
	base_took_damage.emit(objective_health)
	if objective_health <= 0:
		lose_game()
	elif enemies == 0:
		end_wave()
		if wave >= 20:
			win_game()


func end_wave():
	for peer_id in connected_players_nodes:
		connected_players_nodes[peer_id].currency += pot / connected_players_nodes.size()
	level.a_star_graph_3d.visualized_path.enable_visualization()
	wave_finished.emit(wave)
	set_upcoming_wave()
	if wave < 20:
		for key in connected_players_nodes:
			connected_players_nodes[key].hud.set_upcoming_wave(upcoming_wave)


func remove_player(peer_id):
	connected_players_nodes[peer_id].queue_free()
	connected_players_nodes.erase(peer_id)


func start_game():
	game_active = true
	level.a_star_graph_3d.make_grid()
	level.a_star_graph_3d.find_path()
	set_upcoming_wave()
	for peer_id in connected_players_nodes:
		connected_players_nodes[peer_id].currency = 20
		connected_players_nodes[peer_id].hud.set_upcoming_wave(upcoming_wave)
	game_started.emit()


func restart_game():
	#implement game reloading system
	for peer_id in connected_players_nodes:
		connected_players_nodes[peer_id].queue_free()
	connected_players_nodes.clear()
	level.queue_free()
	enemies = 0
	objective_health = 100
	wave = 0
	spawn_level()
	game_restarted.emit()
	pass


func lose_game():
	if game_active == false:
		return
	game_active = false
	var menu = lose_game_scene.instantiate()
	add_child(menu)
	lost_game.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for peer_id in connected_players_nodes:
		connected_players_nodes[peer_id].pause()


func win_game():
	if game_active == false:
		return
	game_active = false
	var menu = won_game_scene.instantiate()
	add_child(menu)
	won_game.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for peer_id in connected_players_nodes:
		connected_players_nodes[peer_id].pause()


func quit_to_desktop():
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	get_tree().quit()


func scene_switch_main_menu():
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	for node in get_children():
		node.queue_free()
	get_tree().change_scene_to_file(main_menu_scene_path)


func scene_switch_to_multiplayer_lobby():
	get_tree().change_scene_to_file(multiplayer_lobby_scene_path)


func scene_switch_to_singleplayer_lobby():
	get_tree().change_scene_to_file(singleplayer_lobby_scene_path)
