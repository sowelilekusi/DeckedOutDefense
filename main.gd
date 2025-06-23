class_name Main
extends Node

signal loaded_scene

@export var scene: Node
@export var movies: Node

var game_manager: GameManager
var loaded: bool = false
var main_menu_scene_path: String = "res://Scenes/Menus/MainMenu/main_menu.tscn"
var multiplayer_lobby_scene_path: String = "res://Scenes/Menus/multiplayer_lobby.tscn"
var singleplayer_lobby_scene_path: String = "res://Scenes/Menus/singleplayer_lobby.tscn"


func load_main_menu() -> void:
	load_scene(main_menu_scene_path)
	await loaded_scene
	if game_manager:
		game_manager.queue_free()
	game_manager = GameManager.new()
	add_child(game_manager)
	game_manager.switch_to_main_menu.connect(load_main_menu)
	game_manager.switch_to_single_player.connect(load_singleplayer)
	game_manager.switch_to_multi_player.connect(load_multiplayer)
	var main_menu: MainMenu = scene.get_child(0) as MainMenu
	main_menu.multiplayer_game_requested.connect(load_multiplayer)
	main_menu.singleplayer_game_requested.connect(load_singleplayer)
	main_menu.game = game_manager


func load_singleplayer() -> void:
	load_scene(singleplayer_lobby_scene_path)
	await loaded_scene
	var single_player_lobby: SinglePlayerLobby = scene.get_child(0) as SinglePlayerLobby
	single_player_lobby.game_manager = game_manager
	single_player_lobby.setup_game()


func load_multiplayer() -> void:
	load_scene(multiplayer_lobby_scene_path)
	await loaded_scene
	var multi_player_lobby: MultiplayerLobby = scene.get_child(0) as MultiplayerLobby
	multi_player_lobby.game_manager = game_manager


func load_scene(scene_path: String) -> void:
	ResourceLoader.load_threaded_request(scene_path)
	for node: Node in scene.get_children():
		node.queue_free()
	var progress: Array = [0.0]
	while progress[0] < 1.0:
		await get_tree().process_frame
		ResourceLoader.load_threaded_get_status(scene_path, progress)
		if progress[0] >= 1.0:
			var new_scene: PackedScene = ResourceLoader.load_threaded_get(scene_path)
			if movies:
				movies.queue_free()
				movies = null
				$CanvasLayer.visible = true
			scene.add_child(new_scene.instantiate())
			loaded_scene.emit()
