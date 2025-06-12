class_name Main
extends SubViewportContainer

var loaded: bool = false

func _ready() -> void:
	ResourceLoader.load_threaded_request("res://Scenes/Menus/MainMenu/main_menu.tscn")


func _process(delta: float) -> void:
	if !loaded:
		var progress: Array = []
		ResourceLoader.load_threaded_get_status("res://Scenes/Menus/MainMenu/main_menu.tscn", progress)
		$SubViewport/ProgressBar.value = progress[0] * 100.0
		if progress[0] >= 1.0:
			$SubViewport/ProgressBar.queue_free()
			var main_menu: PackedScene = ResourceLoader.load_threaded_get("res://Scenes/Menus/MainMenu/main_menu.tscn")
			$SubViewport/Node.add_child(main_menu.instantiate())
			loaded = true
