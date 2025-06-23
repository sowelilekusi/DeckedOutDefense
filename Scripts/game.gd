class_name GameManager
extends Node

signal wave_started(wave_number: int)
signal wave_finished(wave_number: int)
signal base_took_damage(remaining_health: int)
signal game_setup
signal game_started
signal lost_game
signal won_game
signal rng_seeded
signal switch_to_single_player
signal switch_to_multi_player
signal switch_to_main_menu

var level_scene: PackedScene = load("res://Worlds/GreenPlanet/Levels/first_level.tscn")
var player_scene: PackedScene = load("res://PCs/hero.tscn")
var game_end_scene: PackedScene = load("res://Scenes/Menus/GameEndScreen/game_end_screen.tscn")
var connected_players_nodes: Dictionary = {}
var game_active: bool = false
var gamemode: GameMode = null
var level: Level
var enemies: int = 0
var objective_health: int = 120
var wave: int = 0
var pot: float
var UILayer: CanvasLayer
var chatbox: Chatbox
var wave_limit: int = 20
var starting_cash: int = 25
var shop_chance: float = 0.0
var stats: RoundStats


#TODO: Create a reference to some generic Lobby object that wraps the multiplayer players list stuff
var connected_player_profiles: Dictionary = {}


func _ready() -> void:
	UILayer = CanvasLayer.new()
	UILayer.layer = 2
	get_tree().root.add_child.call_deferred(UILayer)
	var version_label: Label = Label.new()
	var version: String = ProjectSettings.get_setting("application/config/version")
	version_label.text = "WORK IN PROGRESS | ALPHA - VERSION " + version + " | PLAYTEST"
	version_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version_label.add_theme_font_size_override("font_size", 18)
	version_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 0.7))
	version_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	UILayer.add_child(version_label)
	Input.set_custom_mouse_cursor(load("res://Assets/Textures/cursor_none.png"), Input.CURSOR_ARROW, Vector2(9, 6))
	Input.set_custom_mouse_cursor(load("res://Assets/Textures/bracket_b_vertical.png"), Input.CURSOR_IBEAM, Vector2(16, 16))


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
		chatbox.append_message("SERVER", Color.TOMATO, str(NoiseRandom.noise.seed))
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
	level.game_manager = self
	for x: EnemySpawner in level.enemy_spawns:
		#x.path = level.a_star_graph_3d.visualized_path
		x.game_manager = self
		x.enemy_died_callback = enemy_died
		x.enemy_reached_goal_callback = damage_goal
		x.enemy_spawned.connect(increase_enemy_count)
	add_child(level)


func spawn_players() -> void:
	var p_i: int = 0
	var player_array: Array = connected_player_profiles.keys()
	player_array.sort()
	for peer_id: int in player_array:
		var player: Hero = player_scene.instantiate() as Hero
		player.name = str(peer_id)
		player.game_manager = self
		player.edit_tool.level = level
		player.hud.map_anchor = level
		player.player_name_tag.text = connected_player_profiles[peer_id].display_name
		player.position = level.player_spawns[p_i].global_position
		player.profile = connected_player_profiles[peer_id]
		player.hero_class = Data.characters[connected_player_profiles[peer_id].preferred_class]
		player.ready_state_changed.connect(ready_player)
		if peer_id == multiplayer.get_unique_id():
			chatbox.opened.connect(player.pause)
			chatbox.closed.connect(player.unpause)
		player.set_multiplayer_authority(peer_id)
		connected_players_nodes[peer_id] = player
		wave_started.connect(player.exit_editing_mode)
		wave_finished.connect(player.enter_editing_mode)
		base_took_damage.connect(player.hud.set_lives_count)
		add_child(player)
		p_i += 1
	level.cinematic_cam.does_its_thing = false


func ready_player(player_ready_true: bool) -> void:
	if !player_ready_true:
		return
	var ready_players: int = 0
	for key: int in connected_players_nodes:
		if connected_players_nodes[key].ready_state == false:
			continue
		else:
			ready_players += 1
	if ready_players == connected_players_nodes.size():
		spawn_enemy_wave()
		#chatbox.append_message("SERVER", Color.TOMATO, "Wave Started!")
	else:
		chatbox.append_message("SERVER", Color.TOMATO, str(ready_players) + "/" + str(connected_players_nodes.size()) + " Players ready")


func spawn_enemy_wave() -> void:
	level.shop.close()
	wave += 1
	level.disable_all_tower_frames()
	#level.a_star_graph_3d.find_path()
	#level.a_star_graph_3d.disable_all_tower_frames()
	level.flow_field.calculate()
	for spawn: EnemySpawner in level.enemy_spawns:
		#spawn.path.disable_visualization()
		spawn.spawn_wave()
	wave_started.emit(wave)


func set_upcoming_wave() -> void:
	if is_multiplayer_authority():
		var spawn_power: int = WaveManager.calculate_spawn_power(wave + 1, connected_players_nodes.size())
		#var new_wave: Dictionary = WaveManager.generate_wave(spawn_power, level.enemy_pool)
		var new_wave: Wave = WaveManager.generate_wave(spawn_power, level.enemy_pool, level.enemy_spawns)
		temp_set_upcoming_wave(new_wave, WaveManager.calculate_pot(wave + 1, connected_players_nodes.size()))
		#networked_set_upcoming_wave.rpc(new_wave, 6 + floori(spawn_power / 70.0))


func temp_set_upcoming_wave(wave: Wave, coins: int) -> void:
	pot = coins
	connected_players_nodes[multiplayer.get_unique_id()].hud.show_wave_generation_anim(wave)
	connected_players_nodes[multiplayer.get_unique_id()].hud.set_upcoming_wave(wave.to_dict())

#TODO: You'll probably have to write a to_dict function for the new wave system 
#before any of this shit works in multiplayer
#@rpc("reliable", "call_local")
#func networked_set_upcoming_wave(wave_dict: Dictionary, coins: int) -> void:
	#upcoming_wave = wave_dict
	#pot = coins
	#for key: int in connected_players_nodes:
		#connected_players_nodes[key].hud.set_upcoming_wave(upcoming_wave)


@rpc("reliable", "call_local")
func networked_set_endless(value: bool) -> void:
	gamemode.endless = value
	if gamemode.endless:
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
		if !gamemode.endless and wave >= wave_limit:
			end(true)


func damage_goal(enemy: Enemy, penalty: int) -> void:
	enemies -= 1
	stats.add_enemy_undefeated(wave, enemy)
	for key: int in connected_players_nodes:
		connected_players_nodes[key].hud.enemy_count_down(enemy)
	objective_health -= penalty
	base_took_damage.emit(objective_health)
	if objective_health <= 0:
		end(false)
	elif enemies == 0:
		end_wave()
		if !gamemode.endless and wave >= wave_limit:
			end(true)


func end_wave() -> void:
	for peer_id: int in connected_players_nodes:
		connected_players_nodes[peer_id].currency += ceili(pot / connected_players_nodes.size())
		connected_players_nodes[peer_id].unready_self()
	for spawn: EnemySpawner in level.enemy_spawns:
		spawn.path.enable_visualization()
	#level.a_star_graph_3d.enable_non_path_tower_frames()
	level.enable_non_path_tower_frames()
	if is_multiplayer_authority():
		if NoiseRandom.randf_in_range(23 * wave, 0.0, 1.0) <= shop_chance:
			networked_spawn_shop.rpc()
			shop_chance = 0.0
		else:
			shop_chance += 0.09
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


func setup() -> void:
	#clean up old stuff
	if level:
		level.queue_free()
	for peer_id: int in connected_players_nodes:
		connected_players_nodes[peer_id].queue_free()
	connected_players_nodes.clear()
	
	#Spawn new stuff
	spawn_level()
	
	#Set starting parameters
	game_active = false
	enemies = 0
	objective_health = 120
	wave = 0
	stats = RoundStats.new()
	game_setup.emit()


@rpc("reliable", "call_local")
func set_seed(value: int) -> void:
	NoiseRandom.set_seed(value)
	rng_seeded.emit()


func start() -> void:
	if is_multiplayer_authority():
		set_seed.rpc(gamemode.rng_seed)
	else:
		await rng_seeded
	
	#Relies on player list having been decided
	spawn_players()
	for peer_id: int in connected_players_nodes:
		connected_players_nodes[peer_id].currency = ceili(float(starting_cash) / float(connected_players_nodes.size()))
	
	#Relies on rng having been seeded
	set_upcoming_wave()
	level.flow_field.calculate()
	level.enemy_spawns[0].update_path()
	#level.a_star_graph_3d.make_grid()
	level.generate_obstacles()
	level.enable_non_path_tower_frames()
	#level.a_star_graph_3d.disable_all_tower_frames()
	#level.a_star_graph_3d.enable_non_path_tower_frames()z
	#level.a_star_graph_3d.find_path()
	
	#Start game
	game_active = true
	chatbox.append_message("SERVER", Color.TOMATO, "Started with seed: " + str(NoiseRandom.noise.seed))
	game_started.emit()
	#print("started game with seed: " + str(gamemode.rng_seed))


func end(outcome: bool) -> void:
	if game_active == false:
		return
	game_active = false
	Data.save_data.add_game_outcome(outcome)
	Data.save_data.save_to_disc()
	var menu: GameEndScreen = game_end_scene.instantiate() as GameEndScreen
	menu.game_manager = self
	match outcome:
		false:
			menu.set_outcome_message("You lost...")
			lost_game.emit()
		true:
			menu.set_outcome_message("You win!")
			won_game.emit()
	UILayer.add_child(menu)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	connected_players_nodes[multiplayer.get_unique_id()].pause()


func quit_to_desktop() -> void:
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	get_tree().quit()


func scene_switch_main_menu() -> void:
	for node: Node in get_children():
		node.queue_free()
	level = null
	connected_players_nodes.clear()
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	switch_to_main_menu.emit()
	#get_tree().change_scene_to_file(main_menu_scene_path)


func scene_switch_to_multiplayer_lobby() -> void:
	switch_to_multi_player.emit()
	#get_tree().change_scene_to_file(multiplayer_lobby_scene_path)


func scene_switch_to_singleplayer_lobby() -> void:
	switch_to_single_player.emit()
	#get_tree().change_scene_to_file(singleplayer_lobby_scene_path)
