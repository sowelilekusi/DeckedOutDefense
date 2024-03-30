class_name HUD extends CanvasLayer

var last_lives_count: int = 120
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
var minimap_anchor: Node3D
var enemy_names: Array[String]
@export var enemy_sprites: Array[TextureRect]
@export var enemy_counts: Array[Label]
@export var weapon_energy_bar: TextureProgressBar
@export var offhand_energy_bar: TextureProgressBar
@export var pickup_notif_scene: PackedScene
@export var wave_start_label: RichTextLabel
@export var place_icon: TextureRect
@export var swap_icon: TextureRect
@export var place_text: RichTextLabel
@export var swap_text: RichTextLabel

var audio_guard: bool = false


func set_energy_visible(value: bool) -> void:
	weapon_energy_bar.set_visible(value)


func set_offhand_energy_visible(value: bool) -> void:
	offhand_energy_bar.set_visible(value)


func _process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	wave_start_label.text = parse_action_tag("[center]Press #Ready# to start wave")
	place_text.text = parse_action_tag("[center]#Equip In Gauntlet#")
	swap_text.text = parse_action_tag("[center]#Secondary Fire#")


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
	hover_text.text = parse_action_tag(text)
	hover_text.set_visible(true)


func unset_hover_text() -> void:
	hover_text.set_visible(false)


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
	for index: int in value:
		wave[Data.enemies[index]] = value[index]
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


func set_weapon_energy(value: int) -> void:
	weapon_energy_bar.value = value
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


func set_offhand_energy(value: int) -> void:
	offhand_energy_bar.value = value


func maximise_minimap(anchor: Node3D) -> void:
	minimap_cam.anchor = anchor
	minimap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	minimap.offset_bottom = -40
	minimap.offset_top = 40
	minimap.offset_left = 40
	minimap.offset_right = -40
	minimap_viewport.size = Vector2(1840, 1000)
	minimap_cam.size = 30
	minimap_outline.set_visible(false)
	currency_count.set_visible(false)


func minimize_minimap(anchor: Node3D) -> void:
	minimap_cam.anchor = anchor
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
	if string_array.size() > 1:
		var event: InputEvent = InputMap.action_get_events(string_array[1])[0]
		if event is InputEventKey:
			string_array[1] = "[img=top,50]%s[/img]" % KeyIconMap.keys[str(event.keycode)]
		if event is InputEventMouseButton:
			string_array[1] = "[img=top,50]%s[/img]" % KeyIconMap.mouse_buttons[str(event.button_index)]
	text = "".join(string_array)
	return text
