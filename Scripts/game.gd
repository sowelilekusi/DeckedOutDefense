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
var endless_mode := false
var upcoming_wave
var pot : float
var UILayer : CanvasLayer
var chatbox : Chatbox
var wave_limit := 20
var starting_cash := 16
var shop_chance := 0.0


func _ready() -> void:
	UILayer = CanvasLayer.new()
	UILayer.layer = 2
	get_tree().root.add_child.call_deferred(UILayer)


func parse_command(text : String, peer_id : int):
	if text.substr(1, 4) == "give":
		var gift_name = text.substr(6) as String
		var gift = Data.cards[0]
		for x in Data.cards:
			if x.title == gift_name:
				gift = x
		connected_players_nodes[peer_id].inventory.add(gift)
	if text.substr(1, 2) == "tr":
		chatbox.append_message("SERVER", Color.TOMATO, "[color=#f7a8b8]t[color=#55cdfc]r[color=#ffffff]a[color=#55cdfc]n[color=#f7a8b8]s [color=#e50000]r[color=#ff8d00]i[color=#ffee00]g[color=#028121]h[color=#004cff]t[color=#760088]s[color=white]!!")
	if text.substr(1, 11) == "random_maze":
		level.a_star_graph_3d.build_random_maze(50)
	if text.substr(1, 13) == "random_towers":
		level.a_star_graph_3d.place_random_towers(level.a_star_graph_3d.tower_bases.size() / 3.0)
	if text.substr(1, 11) == "set_endless":
		if is_multiplayer_authority():
			networked_set_endless.rpc(true)
		else:
			chatbox.append_message("SERVER", Color.TOMATO, "Unable to edit gamemode")
	if text.substr(1, 12) == "set_standard":
		if is_multiplayer_authority():
			networked_set_endless.rpc(false)
		else:
			chatbox.append_message("SERVER", Color.TOMATO, "Unable to edit gamemode")
	if text.substr(1, 11) == "spawn_print":
		level.printer._on_static_body_3d_button_interacted(0)
	if text.substr(1, 10) == "spawn_shop":
		level.shop.randomize_cards()
	if text.substr(1, 7) == "prosper":
		for id in connected_players_nodes:
			connected_players_nodes[id].currency += 50
	if text.substr(1, 8) == "set_wave":
		if is_multiplayer_authority():
			networked_set_wave.rpc(int(text.substr(10)))
		else:
			chatbox.append_message("SERVER", Color.TOMATO, "Unable to set wave")
#	if text.substr(1, 17) == "show tower ranges":
#		pass
#	if text.substr(1, 20) = "show gauntlet ranges":
#		pass


@rpc("reliable", "call_local")
func networked_set_wave(wave_number):
	chatbox.append_message("SERVER", Color.TOMATO, "Set to wave " + str(wave_number))
	for player in connected_players_nodes:
		connected_players_nodes[player].hud.set_wave_count(wave_number)
	wave = wave_number
	set_upcoming_wave()


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
		player.player_name_tag.text = player_profiles[peer_id].display_name
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
	level.cinematic_cam.does_its_thing = false
	start_game()


func ready_player(_value):
	for key in connected_players_nodes:
		if connected_players_nodes[key].ready_state == false:
			return
	spawn_enemy_wave()


func spawn_enemy_wave():
	level.shop.close()
	wave += 1
	level.a_star_graph_3d.find_path()
	level.a_star_graph_3d.visualized_path.disable_visualization()
	level.a_star_graph_3d.disable_all_tower_frames()
	for spawn in level.enemy_spawns:
		spawn.spawn_wave(upcoming_wave)
	wave_started.emit(wave)


func set_upcoming_wave():
	if is_multiplayer_authority():
		var spawn_power = WaveManager.calculate_spawn_power(wave + 1, connected_players_nodes.size())
		var new_wave = WaveManager.generate_wave(spawn_power, level.enemy_pool)
		networked_set_upcoming_wave.rpc(new_wave, 6 + floori(spawn_power / 70))


@rpc("reliable", "call_local")
func networked_set_upcoming_wave(wave_dict, coins):
	upcoming_wave = wave_dict
	pot = coins
	for key in connected_players_nodes:
		connected_players_nodes[key].hud.set_upcoming_wave(upcoming_wave)


@rpc("reliable", "call_local")
func networked_set_endless(value):
	endless_mode = value
	if endless_mode:
		chatbox.append_message("SERVER", Color.TOMATO, "Endless mode enabled!")
	else:
		chatbox.append_message("SERVER", Color.TOMATO, "Endless mode disabled!")


func increase_enemy_count():
	enemies += 1
	enemy_number_changed.emit(enemies)


func enemy_died(enemy):
	enemies -= 1
	enemy_number_changed.emit(enemies)
	for key in connected_players_nodes:
		connected_players_nodes[key].hud.enemy_count_down(enemy)
	for x in level.enemy_spawns:
		if !x.done_spawning:
			return
	if enemies == 0:
		end_wave()
		if !endless_mode and wave >= wave_limit:
			win_game()


func damage_goal(enemy, penalty):
	enemies -= 1
	enemy_number_changed.emit(enemies)
	for key in connected_players_nodes:
		connected_players_nodes[key].hud.enemy_count_down(enemy)
	objective_health -= penalty
	base_took_damage.emit(objective_health)
	if objective_health <= 0:
		lose_game()
	elif enemies == 0:
		end_wave()
		if !endless_mode and wave >= wave_limit:
			win_game()


func end_wave():
	for peer_id in connected_players_nodes:
		connected_players_nodes[peer_id].currency += ceili(pot / connected_players_nodes.size())
		connected_players_nodes[peer_id].ready_state = false
	level.a_star_graph_3d.visualized_path.enable_visualization()
	level.a_star_graph_3d.enable_non_path_tower_frames()
	if is_multiplayer_authority():
		if randf() <= shop_chance:
			networked_spawn_shop.rpc()
			shop_chance = 0.0
		else:
			shop_chance += 0.05
	wave_finished.emit(wave)
	set_upcoming_wave()


@rpc("reliable", "call_local")
func networked_spawn_shop():
	level.shop.randomize_cards()
	chatbox.append_message("SERVER", Color.TOMATO, "A shopkeeper has arrived!")


func remove_player(peer_id):
	if connected_players_nodes.has(peer_id):
		connected_players_nodes[peer_id].queue_free()
		connected_players_nodes.erase(peer_id)


func start_game():
	game_active = true
	enemies = 0
	objective_health = 120
	wave = 0
	level.a_star_graph_3d.make_grid()
	level.a_star_graph_3d.find_path()
	set_upcoming_wave()
	for peer_id in connected_players_nodes:
		connected_players_nodes[peer_id].currency = starting_cash / connected_players_nodes.size()
	game_started.emit()


func restart_game():
	#implement game reloading system
	for peer_id in connected_players_nodes:
		connected_players_nodes[peer_id].queue_free()
	connected_players_nodes.clear()
	level.queue_free()
	enemies = 0
	objective_health = 120
	wave = 0
	spawn_level()
	game_restarted.emit()
	pass


func lose_game():
	if game_active == false:
		return
	game_active = false
	var menu = lose_game_scene.instantiate()
	UILayer.add_child(menu)
	lost_game.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for peer_id in connected_players_nodes:
		connected_players_nodes[peer_id].pause()


func win_game():
	if game_active == false:
		return
	game_active = false
	var menu = won_game_scene.instantiate()
	UILayer.add_child(menu)
	won_game.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for peer_id in connected_players_nodes:
		connected_players_nodes[peer_id].pause()


func quit_to_desktop():
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	get_tree().quit()


func scene_switch_main_menu():
	for node in get_children():
		node.queue_free()
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file(main_menu_scene_path)


func scene_switch_to_multiplayer_lobby():
	get_tree().change_scene_to_file(multiplayer_lobby_scene_path)


func scene_switch_to_singleplayer_lobby():
	get_tree().change_scene_to_file(singleplayer_lobby_scene_path)
