extends Node

signal wave_started(wave_number: int)
signal wave_finished(wave_number: int)
signal base_took_damage(remaining_health: int)
signal rng_seeded()
signal game_started
signal game_restarted
signal lost_game
signal won_game

var level_scene: PackedScene = load("res://Worlds/GreenPlanet/Levels/first_level.tscn")
var player_scene: PackedScene = load("res://PCs/hero.tscn")
var main_menu_scene_path: String = "res://Scenes/Menus/MainMenu/main_menu.tscn"
var multiplayer_lobby_scene_path: String = "res://Scenes/Menus/multiplayer_lobby.tscn"
var singleplayer_lobby_scene_path: String = "res://Scenes/Menus/singleplayer_lobby.tscn"
var won_game_scene: PackedScene = load("res://Scenes/Menus/won_game_screen.tscn")
var lose_game_scene: PackedScene = load("res://Scenes/Menus/lost_game_screen.tscn")
var connected_players_nodes: Dictionary = {}
var game_active: bool = false
var level: Level
var enemies: int = 0
var objective_health: int = 120
var wave: int = 0
var endless_mode: bool = false
var upcoming_wave: Dictionary
var pot: float
var UILayer: CanvasLayer
var chatbox: Chatbox
var wave_limit: int = 20
var starting_cash: int = 16
var shop_chance: float = 0.0
var stats: RoundStats = RoundStats.new()
var rng: FastNoiseLite


func _ready() -> void:
	UILayer = CanvasLayer.new()
	UILayer.layer = 2
	get_tree().root.add_child.call_deferred(UILayer)


@rpc("reliable", "call_local")
func set_seed(value: int) -> void:
	rng = FastNoiseLite.new()
	rng.noise_type = FastNoiseLite.TYPE_VALUE
	rng.frequency = 1
	rng.seed = value
	rng_seeded.emit()


func randi_in_range(sample: float, start: float, end: float) -> int:
	return floori(remap(rng.get_noise_1d(sample), -1.0, 1.0, start, end + 1))


func parse_command(text: String, peer_id: int) -> void:
	if text.substr(1, 4) == "give":
		var gift_name: String = text.substr(6) as String
		var gift: Card = Data.cards[0]
		for x: Card in Data.cards:
			if x.display_name == gift_name:
				gift = x
		connected_players_nodes[peer_id].inventory.add(gift)
	elif text.substr(1, 2) == "tr":
		chatbox.append_message("SERVER", Color.TOMATO, "[color=#f7a8b8]t[color=#55cdfc]r[color=#ffffff]a[color=#55cdfc]n[color=#f7a8b8]s [color=#e50000]r[color=#ff8d00]i[color=#ffee00]g[color=#028121]h[color=#004cff]t[color=#760088]s[color=white]!!")
	elif text.substr(1, 6) == "length":
		chatbox.append_message("SERVER", Color.TOMATO, str(level.a_star_graph_3d.visualized_path.curve.get_baked_length()))
	elif text.substr(1, 11) == "random_maze":
		level.a_star_graph_3d.build_random_maze(50)
	elif text.substr(1, 13) == "random_towers":
		level.a_star_graph_3d.place_random_towers(floori(level.a_star_graph_3d.tower_bases.size() / 3.0))
	elif text.substr(1, 11) == "set_endless":
		if is_multiplayer_authority():
			networked_set_endless.rpc(true)
		else:
			chatbox.append_message("SERVER", Color.TOMATO, "Unable to edit gamemode")
	elif text.substr(1, 12) == "set_standard":
		if is_multiplayer_authority():
			networked_set_endless.rpc(false)
		else:
			chatbox.append_message("SERVER", Color.TOMATO, "Unable to edit gamemode")
	elif text.substr(1, 11) == "spawn_print":
		level.printer._on_static_body_3d_button_interacted(0, connected_players_nodes[peer_id].inventory)
	elif text.substr(1, 10) == "spawn_shop":
		level.shop.randomize_cards()
	elif text.substr(1, 7) == "prosper":
		for id: int in connected_players_nodes:
			connected_players_nodes[id].currency += 50
	elif text.substr(1, 8) == "set_wave":
		if is_multiplayer_authority():
			networked_set_wave.rpc(int(text.substr(10)))
		else:
			chatbox.append_message("SERVER", Color.TOMATO, "Unable to set wave")
	elif text.substr(1, 4) == "seed":
		chatbox.append_message("SERVER", Color.TOMATO, str(rng.seed))
#	if text.substr(1, 17) == "show tower ranges":
#		pass
#	if text.substr(1, 20) = "show gauntlet ranges":
#		pass


@rpc("reliable", "call_local")
func networked_set_wave(wave_number: int) -> void:
	chatbox.append_message("SERVER", Color.TOMATO, "Set to wave " + str(wave_number))
	for player: int in connected_players_nodes:
		connected_players_nodes[player].hud.set_wave_count(wave_number)
	wave = wave_number
	set_upcoming_wave()


func spawn_level() -> void:
	level = level_scene.instantiate() as Level
	for x: EnemySpawner in level.enemy_spawns:
		#x.path = level.a_star_graph_3d.visualized_path
		x.enemy_died_callback = enemy_died
		x.enemy_reached_goal_callback = damage_goal
		x.enemy_spawned.connect(increase_enemy_count)
	add_child(level)


func spawn_players(player_array: Array, player_profiles: Dictionary, chatbox_open_signal: Signal, chatbox_closed_signal: Signal) -> void:
	var p_i: int = 0
	player_array.sort()
	for peer_id: int in player_array:
		var player: Hero = player_scene.instantiate() as Hero
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
		add_child(player)
		p_i += 1
	level.cinematic_cam.does_its_thing = false
	start_game()


func ready_player(_value: int) -> void:
	for key: int in connected_players_nodes:
		if connected_players_nodes[key].ready_state == false:
			return
	spawn_enemy_wave()


func spawn_enemy_wave() -> void:
	level.shop.close()
	wave += 1
	level.a_star_graph_3d.find_path()
	level.a_star_graph_3d.visualized_path.disable_visualization()
	level.a_star_graph_3d.disable_all_tower_frames()
	for spawn: EnemySpawner in level.enemy_spawns:
		spawn.spawn_wave(upcoming_wave)
	wave_started.emit(wave)


func set_upcoming_wave() -> void:
	if is_multiplayer_authority():
		var spawn_power: int = WaveManager.calculate_spawn_power(wave + 1, connected_players_nodes.size())
		var new_wave: Dictionary = WaveManager.generate_wave(spawn_power, level.enemy_pool)
		networked_set_upcoming_wave.rpc(new_wave, 6 + floori(spawn_power / 70.0))


@rpc("reliable", "call_local")
func networked_set_upcoming_wave(wave_dict: Dictionary, coins: int) -> void:
	upcoming_wave = wave_dict
	pot = coins
	for key: int in connected_players_nodes:
		connected_players_nodes[key].hud.set_upcoming_wave(upcoming_wave)


@rpc("reliable", "call_local")
func networked_set_endless(value: bool) -> void:
	endless_mode = value
	if endless_mode:
		chatbox.append_message("SERVER", Color.TOMATO, "Endless mode enabled!")
	else:
		chatbox.append_message("SERVER", Color.TOMATO, "Endless mode disabled!")


func increase_enemy_count() -> void:
	enemies += 1


func enemy_died(enemy: Enemy) -> void:
	enemies -= 1
	for key: int in connected_players_nodes:
		connected_players_nodes[key].hud.enemy_count_down(enemy)
	for x: EnemySpawner in level.enemy_spawns:
		if !x.done_spawning:
			return
	if enemies == 0:
		end_wave()
		if !endless_mode and wave >= wave_limit:
			win_game()


func damage_goal(enemy: Enemy, penalty: int) -> void:
	enemies -= 1
	stats.add_enemy_undefeated(wave, enemy)
	for key: int in connected_players_nodes:
		connected_players_nodes[key].hud.enemy_count_down(enemy)
	objective_health -= penalty
	base_took_damage.emit(objective_health)
	if objective_health <= 0:
		lose_game()
	elif enemies == 0:
		end_wave()
		if !endless_mode and wave >= wave_limit:
			win_game()


func end_wave() -> void:
	for peer_id: int in connected_players_nodes:
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
func networked_spawn_shop() -> void:
	level.shop.randomize_cards()
	chatbox.append_message("SERVER", Color.TOMATO, "A shopkeeper has arrived!")


func remove_player(peer_id: int) -> void:
	if connected_players_nodes.has(peer_id):
		connected_players_nodes[peer_id].queue_free()
		connected_players_nodes.erase(peer_id)


func start_game() -> void:
	if is_multiplayer_authority():
		set_seed.rpc(randi())
	else:
		await rng_seeded
	game_active = true
	enemies = 0
	objective_health = 120
	wave = 0
	level.a_star_graph_3d.make_grid()
	level.generate_obstacles()
	level.a_star_graph_3d.disable_all_tower_frames()
	level.a_star_graph_3d.enable_non_path_tower_frames()
	level.a_star_graph_3d.find_path()
	set_upcoming_wave()
	for peer_id: int in connected_players_nodes:
		connected_players_nodes[peer_id].currency = roundi(float(starting_cash) / float(connected_players_nodes.size()))
	game_started.emit()


func restart_game() -> void:
	#implement game reloading system
	for peer_id: int in connected_players_nodes:
		connected_players_nodes[peer_id].queue_free()
	connected_players_nodes.clear()
	level.queue_free()
	enemies = 0
	objective_health = 120
	wave = 0
	stats = RoundStats.new()
	spawn_level()
	game_restarted.emit()
	pass


func lose_game() -> void:
	if game_active == false:
		return
	game_active = false
	Data.save_stats.add_game_outcome(false)
	Data.save_stats.save_profile_to_disk()
	var menu: Control = lose_game_scene.instantiate()
	UILayer.add_child(menu)
	lost_game.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for peer_id: int in connected_players_nodes:
		connected_players_nodes[peer_id].pause()


func win_game() -> void:
	if game_active == false:
		return
	game_active = false
	Data.save_stats.add_game_outcome(true)
	Data.save_stats.save_profile_to_disk()
	var menu: Control = won_game_scene.instantiate()
	UILayer.add_child(menu)
	won_game.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for peer_id: int in connected_players_nodes:
		connected_players_nodes[peer_id].pause()


func quit_to_desktop() -> void:
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	get_tree().quit()


func scene_switch_main_menu() -> void:
	for node: Node in get_children():
		node.queue_free()
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file(main_menu_scene_path)


func scene_switch_to_multiplayer_lobby() -> void:
	get_tree().change_scene_to_file(multiplayer_lobby_scene_path)


func scene_switch_to_singleplayer_lobby() -> void:
	get_tree().change_scene_to_file(singleplayer_lobby_scene_path)
