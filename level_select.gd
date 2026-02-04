class_name MenuLevelSelect extends Control

@export var icons: Array[Texture] = []
@export var cassette_image: Texture

var biomes: Dictionary[String, HBoxContainer] = {}
var selected_biome: String = ""

var levels: Array[FloatingElement] = []

@export var level_scene: PackedScene


func _ready() -> void:
	#create_classes()
	make_level_labels()


func make_level_labels() -> void:
	for x: int in 10:
		var margin: FloatingElement = level_scene.instantiate() as FloatingElement
		add_child(margin)
		levels.append(margin)
		margin.set_text("Level " + str(x))
		margin.dest = Vector2(x * 50.0, 0.0)


func move_right() -> void:
	for x: FloatingElement in levels:
		x.dest += (Vector2.LEFT * 50.0)


func move_left() -> void:
	for x: FloatingElement in levels:
		x.dest += (Vector2.RIGHT * 50.0)


func create_classes() -> void:
	var centre: Vector2 = Vector2(get_viewport_rect().size.x / 2.0, get_viewport_rect().size.y / 2.0)
	
	biomes["Engineer"] = create_sprite("Engineer", icons[0])
	biomes["Engineer"].set_position(centre + Vector2(-32.0, 0.0 - 32.0))
	biomes["Mage"] = create_sprite("Mage", icons[1])
	biomes["Mage"].set_position(centre + Vector2(-32.0, 80.0 - 32.0))
	biomes["ThirdClass"] = create_sprite("ThirdClass", icons[2])
	biomes["ThirdClass"].set_position(centre + Vector2(-32.0, 160.0 - 32.0))
	biomes["FourthClass"] = create_sprite("FourthClass", icons[3])
	biomes["FourthClass"].set_position(centre + Vector2(-32.0, 240.0 - 32.0))
	
	selected_biome = "Engineer"
	$Label.text = selected_biome


func move_down() -> void:
	for x: HBoxContainer in biomes.values():
		var tween: Tween = create_tween()
		tween.tween_property(x, "position", x.position + Vector2(0.0, -80.0), 0.3)
	var y: int = biomes.keys().find(selected_biome)
	if y + 1 >= biomes.keys().size():
		y = -1
	selected_biome = biomes.keys()[y + 1]
	$Label.text = selected_biome


func move_up() -> void:
	for x: HBoxContainer in biomes.values():
		var tween: Tween = create_tween()
		tween.tween_property(x, "position", x.position + Vector2(0.0, 80.0), 0.3)
	var y: int = biomes.keys().find(selected_biome)
	if y - 1 < 0:
		y = biomes.keys().size()
	selected_biome = biomes.keys()[y - 1]
	$Label.text = selected_biome


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Move Backward"):
		move_down()
	if Input.is_action_just_pressed("Move Forward"):
		move_up()
	if Input.is_action_just_pressed("Move Right"):
		move_right()
	if Input.is_action_just_pressed("Move Left"):
		move_left()


func create_sprite(text: String, icon: Texture) -> HBoxContainer:
	var hbox: HBoxContainer = HBoxContainer.new()
	var sprite: TextureRect = TextureRect.new()
	var label: Label = Label.new()
	
	add_child(hbox)
	hbox.add_child(sprite)
	hbox.add_child(label)
	
	label.text = text
	sprite.texture = icon
	
	return hbox
