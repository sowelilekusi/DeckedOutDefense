class_name Main
extends Node

@export var scene: Node
@export var movies: Node

var loaded: bool = false
var main_menu_scene_path: String = "res://Scenes/Menus/MainMenu/main_menu.tscn"
var multiplayer_lobby_scene_path: String = "res://Scenes/Menus/multiplayer_lobby.tscn"
var singleplayer_lobby_scene_path: String = "res://Scenes/Menus/singleplayer_lobby.tscn"

func _ready() -> void:
	Game.switch_to_main_menu.connect(load_main_menu)
	Game.switch_to_single_player.connect(load_singleplayer)
	Game.switch_to_multi_player.connect(load_multiplayer)


func load_main_menu() -> void:
	load_scene(main_menu_scene_path)


func load_singleplayer() -> void:
	load_scene(singleplayer_lobby_scene_path)


func load_multiplayer() -> void:
	load_scene(multiplayer_lobby_scene_path)


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
