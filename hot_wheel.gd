class_name HotWheel
extends HBoxContainer

var entries: Array[TextureRect]


func add_cassette(cassette: Card) -> void:
	var tex: TextureRect = TextureRect.new()
	tex.texture = cassette.icon
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.custom_minimum_size = Vector2(32.0, 32.0)
	add_child(tex)
