class_name GameManager
extends Node

signal wave_started()
signal wave_finished()
signal base_took_damage(remaining_health: int)
signal game_setup
signal game_started
signal lost_game
signal won_game
signal rng_seeded
signal switch_to_single_player
signal switch_to_multi_player
signal switch_to_main_menu

var root_scene: Node
var player_scene: PackedScene = load("res://PCs/hero.tscn")
var game_end_scene: PackedScene = load("res://UI/Menus/GameEndScreen/game_end_screen.tscn")
var connected_players_nodes: Dictionary = {}
var game_active: bool = false
var gamemode: GameMode = null
var level: Level
var enemies: int = 0
var objective_health: int = Data.starting_lives
var wave: int
var pot: float
var UILayer: CanvasLayer
var chatbox: Chatbox
var wave_limit: int = 20
var shop_chance: float = 0.0
var stats: RoundStats
var card_gameplay: bool = false
var level_layout: FlowFieldData
var level_specs: LevelSpecs


#TODO: Create a reference to some generic Lobby object that wraps the multiplayer players list stuff
var connected_player_profiles: Dictionary = {}


func parse_command(text: String, peer_id: int) -> void:
	if text.substr(1, 4) == "give":
		var gift_name: String = text.substr(6) as String
		var gift: Card = Data.cards[0]
		for x: Card in Data.cards:
			if x.display_name == gift_name:
				gift = x
		connected_players_nodes[peer_id].hand.add(gift)
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


@rpc("reliable", "call_local")
func networked_set_wave(wave_number: int) -> void:
	chatbox.append_message("SERVER", Color.TOMATO, "Set to wave " + str(wave_number))
	for player: int in connected_players_nodes:
		connected_players_nodes[player].hud.set_wave_count(wave_number)
	wave = wave_number
	set_upcoming_wave()


func spawn_level(scene: PackedScene) -> void:
	level = scene.instantiate() as Level
	var flow_field: FlowField = FlowField.new()
	level.flow_field = flow_field
	level.add_child(flow_field)
	flow_field.load_from_data(FlowFieldTool.load_flow_field_from_disc(level.data_path))
	level.load_flow_field()
	level.game_manager = self
	for x: EnemySpawner in level.enemy_spawns:
		x.flow_field = flow_field
		x.game_manager = self
		x.enemy_died_callback = enemy_died
		x.enemy_reached_goal_callback = damage_goal
		x.enemy_spawned.connect(increase_enemy_count)
	root_scene.add_child(level)
	for spawner: EnemySpawner in level.enemy_spawns:
		spawner.create_path()
	level.generate_obstacle(level_specs.points_blocked)


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
		player.blank_cassettes += Data.starting_blanks
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
		wave_started.connect(player.enter_fighting_state)
		wave_finished.connect(player.exit_fighting_state)
		base_took_damage.connect(player.hud.set_lives_count)
		root_scene.add_child(player)
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
	else:
		chatbox.append_message("SERVER", Color.TOMATO, str(ready_players) + "/" + str(connected_players_nodes.size()) + " Players ready")


func spawn_enemy_wave() -> void:
	#level.shop.close()
	#wave += 1
	level.disable_all_tower_frames()
	level.flow_field.calculate()
	for spawn: EnemySpawner in level.enemy_spawns:
		spawn.visible = false
		spawn.spawn_wave()
	#for tower_base: TowerBase in level.walls.values():
		#tower_base.disable_duration_sprites()
	wave_started.emit()


func pre_generate_waves() -> Array[Wave]:
	var wave_list: Array[Wave] = []
	for i: int in range(wave, wave_limit + 1):
		var spawn_power: int = WaveManager.calculate_spawn_power(i, connected_players_nodes.size())
		var generated_wave: Wave = WaveManager.generate_wave(spawn_power, level.enemy_pool)
		wave_list.append(generated_wave)
	return wave_list


func set_wave_to_spawners(wave_thing: Wave, wave_number: int) -> void:
	var spawners: Array[EnemySpawner] = level.enemy_spawns
	var ground_spawners: Array[EnemySpawner] = []
	var air_spawners: Array[EnemySpawner] = []
	for spawner: EnemySpawner in spawners:
		if spawner.type == Data.EnemyType.LAND:
			ground_spawners.append(spawner)
		else:
			air_spawners.append(spawner)
	var assignment_salt: int = 0
	for card: EnemyCard in wave_thing.enemy_groups:
		assignment_salt += 1
		if card.enemy.target_type == Data.EnemyType.LAND:
			ground_spawners[NoiseRandom.randi_in_range((wave_number * assignment_salt) - assignment_salt, 0, ground_spawners.size() - 1)].add_card(card)
		else:
			air_spawners[NoiseRandom.randi_in_range((wave_number * assignment_salt) + assignment_salt, 0, air_spawners.size() - 1)].add_card(card)


func set_upcoming_wave() -> void:
	if is_multiplayer_authority():
		if level_specs.waves.size() == 0:
			var spawn_power: int = WaveManager.calculate_spawn_power(wave, connected_players_nodes.size())
			#var new_wave: Dictionary = WaveManager.generate_wave(spawn_power, level.enemy_pool)
			var new_wave: Wave = WaveManager.generate_wave(spawn_power, level.enemy_pool)
			set_wave_to_spawners(new_wave, wave)
			temp_set_upcoming_wave(new_wave, WaveManager.calculate_pot(wave, connected_players_nodes.size()))
			#networked_set_upcoming_wave.rpc(new_wave, 6 + floori(spawn_power / 70.0))
		else:
			var new_wave: Wave = Wave.new()
			for enemy: Enemy in level_specs.waves[wave - 1].enemies.keys():
				var enemy_card: EnemyCard = EnemyCard.new()
				enemy_card.enemy = enemy
				enemy_card.count = level_specs.waves[wave - 1].enemies[enemy]
				new_wave.enemy_groups.append(enemy_card)
			set_wave_to_spawners(new_wave, wave)
			temp_set_upcoming_wave(new_wave, WaveManager.calculate_pot(wave, connected_players_nodes.size()))


func temp_set_upcoming_wave(new_wave: Wave, coins: int) -> void:
	pot = coins
	#connected_players_nodes[multiplayer.get_unique_id()].hud.show_wave_generation_anim(new_wave)
	connected_players_nodes[multiplayer.get_unique_id()].hud.set_upcoming_wave(new_wave.to_dict())

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
		if !gamemode.endless and wave > wave_limit:
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
		if !gamemode.endless and wave > wave_limit:
			end(true)


func end_wave() -> void:
	wave += 1
	for peer_id: int in connected_players_nodes:
		var player: Hero = connected_players_nodes[peer_id] as Hero
		player.hud.set_wave_count(wave)
		player.currency += ceili(pot / connected_players_nodes.size())
		player.currency += level_specs.waves[wave - 2].bonus_cash
		player.energy = Data.player_energy
		player.blank_cassettes += 1 if level_specs.waves[wave - 2].rewards_blank_cassette else 0
		#if wave % 2 == 0:
		#	player.blank_cassettes += 1
		if card_gameplay:
			player.iterate_duration()
			player.draw_to_hand_size()
		player.unready_self()
	for spawn: EnemySpawner in level.enemy_spawns:
		spawn.visible = true
	for tower_base: TowerBase in level.walls.values():
		if tower_base.has_card:
			#tower_base.enable_duration_sprites()
			tower_base.iterate_duration()
	if is_multiplayer_authority():
		if level_specs.waves[wave - 2].new_shop:
			networked_spawn_shop.rpc()
		#if NoiseRandom.randf_in_range(23 * wave, 0.0, 1.0) <= shop_chance:
			#networked_spawn_shop.rpc()
			#shop_chance = 0.0
		#else:
			#shop_chance += 0.09
	wave_finished.emit()
	if wave < wave_limit:
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
	spawn_level(level_specs.zone_scene)
	
	#Set starting parameters
	game_active = false
	enemies = 0
	objective_health = Data.starting_lives
	wave = 1
	stats = RoundStats.new()
	wave_limit = level_specs.waves.size()
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
		connected_players_nodes[peer_id].currency = ceili(float(Data.starting_cash) / float(connected_players_nodes.size()))
		if card_gameplay:
			connected_players_nodes[peer_id].energy = Data.player_energy
			connected_players_nodes[peer_id].draw_pile.shuffle()
			connected_players_nodes[peer_id].draw_to_hand_size()
	
	#Relies on rng having been seeded
	set_upcoming_wave()
	level.flow_field.calculate()
	level.enemy_spawns[0].update_path()
	level.generate_obstacles()
	
	#Start game
	game_active = true
	chatbox.append_message("SERVER", Color.TOMATO, "Started with seed: " + str(NoiseRandom.noise.seed))
	#networked_spawn_shop.rpc()
	game_started.emit()


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


func scene_switch_to_multiplayer_lobby() -> void:
	switch_to_multi_player.emit()


func scene_switch_to_singleplayer_lobby() -> void:
	switch_to_single_player.emit()
