class_name HUD
extends CanvasLayer

@export var player: Hero
@export var wave_count: Label
@export var lives_count: Label
@export var currency_count: Label
@export var minimap_outline: TextureRect
@export var crosshair: Control
@export var minimap: TextureRect
@export var minimap_cam: MinimapCamera3D
@export var minimap_viewport: SubViewport
@export var fps_label: Label
@export var hover_text: RichTextLabel
@export var enemy_sprites: Array[TextureRect]
@export var enemy_counts: Array[Label]
@export var pickup_notif_scene: PackedScene
@export var wave_start_label: RichTextLabel
@export var place_icon: TextureRect
@export var swap_icon: TextureRect
@export var place_text: RichTextLabel
@export var swap_text: RichTextLabel
@export var enemy_card_scene: PackedScene
@export var new_energy_bar: EnergyBar

var last_lives_count: int = 120
var enemy_names: Array[String]
var map_anchor: Node3D
var audio_guard: bool = false
var cards: Array[EnemyCardUI] = []


func show_wave_generation_anim(wave: Wave) -> void:
	for card: EnemyCardUI in cards:
		card.queue_free()
	cards = []
	var x: int = 0
	var final_x_coords: Array[int] = [-550, -275, 0, 275, 550]
	for card: EnemyCard in wave.enemy_groups:
		var card_ui: EnemyCardUI = enemy_card_scene.instantiate()
		card_ui.set_enemy(card)
		add_child(card_ui)
		cards.append(card_ui)
		#$Control.add_child(card_ui)
		card_ui.position = $Control2.position
	var i: int = 0
	var j: int = 0
	for card: EnemyCardUI in cards:
		var anchor: Vector2 = $Control3.position
		anchor -= Vector2(int(card.get_child(0).size.x / 2.0), int(card.get_child(0).size.y / 2.0))
		anchor.x += final_x_coords[i]
		var tween: Tween = create_tween()
		tween.tween_interval((0.3 * j) + (1.4 * int(j / 5.0)))
		tween.tween_property(card, "position", anchor, 0.3)
		tween.tween_interval(3.0)
		tween.tween_property(card, "position", anchor + Vector2.UP * 700, 0.5)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_QUINT)
		i += 1
		if i >= final_x_coords.size():
			i = 0
		j += 1


func set_energy_visible(value: bool) -> void:
	new_energy_bar.visible = value


func _process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	wave_start_label.text = parse_action_tag("[center]Press #Ready# to start wave")
	place_text.text = parse_action_tag("[center]#Equip Primary Weapon#")
	swap_text.text = parse_action_tag("[center]#Equip Secondary Weapon#")


func grow_wave_start_label() -> void:
	tween_label(300.0)


func shrink_wave_start_label() -> void:
	tween_label(0.0)


func tween_label(x: float) -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	if x > 0.0:
		tween.tween_callback(wave_start_label.set_visible.bind(true))
	tween.parallel().tween_property(wave_start_label, "offset_left", -x, 0.6)
	tween.parallel().tween_property(wave_start_label, "offset_right", x, 0.6)
	if x <= 0.0:
		tween.tween_callback(wave_start_label.set_visible.bind(false))


func set_hover_text(text: String) -> void:
	$TextureRect2.visible = true
	$TextureRect.visible = false
	hover_text.text = parse_action_tag(text)
	hover_text.visible = true


func unset_hover_text() -> void:
	hover_text.visible = false
	$TextureRect2.visible = false
	$TextureRect.visible = true


func set_wave_count(value: int) -> void:
	wave_count.text = str(value)


func set_lives_count(value: int) -> void:
	lives_count.text = str(value)
	for x: int in last_lives_count - value:
		$LivesBar.take_life()
	last_lives_count = value


func enemy_count_down(enemy: Enemy) -> void:
	var index: int = enemy_names.find(enemy.title)
	var num: int = enemy_counts[index].text.to_int() - 1
	enemy_counts[index].text = str(num)
	if num == 0:
		enemy_counts[index].set_visible(false)
		enemy_sprites[index].set_visible(false)


func set_upcoming_wave(value: Dictionary) -> void:
	var frame_count: int = 0
	enemy_names = []
	var wave: Dictionary = {}
	for key: String in value:
		var new_enemy: Enemy
		for enemy: Enemy in player.game_manager.level.enemy_pool:
			if enemy.title == key:
				new_enemy = enemy
		wave[new_enemy] = value[key]
	for x: int in enemy_sprites.size():
		enemy_sprites[x].set_visible(false)
		enemy_counts[x].set_visible(false)
	for enemy: Enemy in wave:
		enemy_names.append(enemy.title)
		enemy_sprites[frame_count].texture = enemy.icon
		enemy_counts[frame_count].text = str(wave[enemy])
		enemy_sprites[frame_count].set_visible(true)
		enemy_counts[frame_count].set_visible(true)
		frame_count += 1


func set_currency_count(value: int) -> void:
	currency_count.text = str(value)


func set_crosshair_visible(value: bool) -> void:
	crosshair.set_visible(value)

#TODO: the fuck is audio_guard for?
@warning_ignore("unused_parameter")
func set_weapon_energy(value: int, energy_type: Data.EnergyType) -> void:
	#weapon_energy_bar.value = value
	if player.editing_mode:
		audio_guard = true
	if value == 0 and !audio_guard:
		player.zeropower_audio.play()
		audio_guard = true
	if value == 100 and !audio_guard:
		player.fullpower_audio.play()
		audio_guard = true
	if value > 0 and value < 100:
		audio_guard = false


func maximise_minimap() -> void:
	minimap_cam.anchor = map_anchor
	minimap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	minimap.offset_bottom = -40
	minimap.offset_top = 40
	minimap.offset_left = 40
	minimap.offset_right = -40
	minimap_viewport.size = Vector2(1840, 1000)
	minimap_cam.size = 30
	minimap_outline.set_visible(false)
	currency_count.set_visible(false)


func minimize_minimap() -> void:
	minimap_cam.anchor = player
	minimap.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	minimap.offset_right = -40
	minimap.offset_top = 40
	minimap.offset_left = -256
	minimap.offset_bottom = 256
	minimap_viewport.size = Vector2(256, 256)
	minimap_cam.size = 15
	minimap_outline.set_visible(true)
	currency_count.set_visible(true)


func pickup(card: Card) -> void:
	var notif: PickupNotification = pickup_notif_scene.instantiate()
	notif.set_card(card)
	$VBoxContainer.add_child(notif)


func parse_action_tag(text: String) -> String:
	var string_array: PackedStringArray = text.split("#")
	var output: Array[String] = []
	if string_array.size() > 1:
		for i: int in InputMap.action_get_events(string_array[1]).size():
			var event: InputEvent = InputMap.action_get_events(string_array[1])[i]
			if InputMap.action_get_events(string_array[1]).size() > 1:
				var last: bool = true if i == InputMap.action_get_events(string_array[1]).size() - 1 else false
				var first: bool = true if i == 0 else false
				if last:
					output.append(" or ")
				elif !first:
					output.append(", ")
			if event is InputEventKey:
				output.append("[img=top,50]%s[/img]" % KeyIconMap.keys[str(event.physical_keycode)])
			if event is InputEventMouseButton:
				output.append("[img=top,50]%s[/img]" % KeyIconMap.mouse_buttons[str(event.button_index)])
	string_array[1] = "".join(output)
	text = "".join(string_array)
	return text
