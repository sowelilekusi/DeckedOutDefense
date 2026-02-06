class_name HUD
extends CanvasLayer

@export var player: Hero
@export var wave_count: Label
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
@export var place_text: RichTextLabel
@export var swap_text: RichTextLabel
@export var enemy_card_scene: PackedScene
@export var energy_label: Label
@export var primary_duration: Label
@export var secondary_duration: Label
@export var blank_cassette_label: Label
@export var feature_preview: HBoxContainer
@export var hot_wheel: HotWheel
@export var shield_ui: ShieldUI
@export var currencies: VBoxContainer
@export var energy_pips: EnergyPips
@export var enemy_count_label: Label
@export var primary_button: Button
@export var secondary_button: Button
@export var null_icon: Texture
@export var slots: VBoxContainer

var last_lives_count: int = Data.starting_lives
var enemy_names: Array[String]
var map_anchor: Node3D
var feature_preview_tween: Tween
var enemy_count: int = 0


func _ready() -> void:
	$StartWaveLabel.theme_type_variation = "WaveStartLabel"
	$InteractLabel.theme_type_variation = "InteractLabel"
	if player.game_manager and player.game_manager.card_gameplay:
		energy_label.visible = true


func enable_card_gameplay_ui() -> void:
	energy_label.visible = true


func disable_card_gameplay_ui() -> void:
	energy_label.visible = false


func show_hot_wheel() -> void:
	hot_wheel.visible = true


func hide_hot_wheel() -> void:
	hot_wheel.visible = false


func show_slots() -> void:
	slots.visible = true


func hide_slots() -> void:
	slots.visible = false


func set_primary_button(card: Card) -> void:
	if card:
		primary_button.icon = card.icon
	else:
		primary_button.icon = null_icon


func set_secondary_button(card: Card) -> void:
	if card:
		secondary_button.icon = card.icon
	else:
		secondary_button.icon = null_icon


func set_blank_cassette_count(value: int) -> void:
	blank_cassette_label.text = str(value)


func set_energy_visible(value: bool) -> void:
	energy_pips.visible = value


func _process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	wave_start_label.text = parse_action_tag(tr("PROMPT_START_WAVE"))
	place_text.text = parse_action_tag("[center]%Primary Fire%")
	swap_text.text = parse_action_tag("[center]%Secondary Fire%")


func show_features(cassette: Card) -> void:
	for child: Node in feature_preview.get_children():
		child.queue_free()
	var cols: int = max(cassette.tower_stats.features.size(), cassette.weapon_stats.features.size())
	for x: int in cols:
		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_END
		if x < cassette.tower_stats.features.size():
			vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
			var tex: TextureRect = TextureRect.new()
			tex.texture = cassette.tower_stats.features[x].icon
			vbox.add_child(tex)
		if x < cassette.weapon_stats.features.size():
			var tex: TextureRect = TextureRect.new()
			tex.texture = cassette.weapon_stats.features[x].icon
			vbox.add_child(tex)
		feature_preview.add_child(vbox)
	if feature_preview_tween:
		feature_preview_tween.kill()
	feature_preview_tween = create_tween()
	feature_preview_tween.set_ease(Tween.EASE_OUT)
	feature_preview_tween.set_trans(Tween.TRANS_CUBIC)
	feature_preview.modulate = Color.WHITE
	feature_preview_tween.tween_interval(0.7)
	feature_preview_tween.tween_property(feature_preview, "modulate", Color8(255, 255, 255, 0), 0.5)


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
	hover_text.text = tr(parse_action_tag(text))
	hover_text.visible = true


func unset_hover_text() -> void:
	hover_text.visible = false
	$TextureRect2.visible = false
	$TextureRect.visible = true


func set_wave_count(value: int) -> void:
	wave_count.text = str(value)


func set_lives_count(value: int) -> void:
	var damage: int = last_lives_count - value
	shield_ui.take_damage(damage)
	last_lives_count = value


func set_currencies_visible(value: bool) -> void:
	currencies.visible = value


func set_energy_pips(value: int) -> void:
	energy_pips.energy = value


func enemy_count_down(enemy: Enemy) -> void:
	var index: int = enemy_names.find(enemy.title)
	var num: int = enemy_counts[index].text.to_int() - 1
	enemy_counts[index].text = str(num)
	if num == 0:
		enemy_counts[index].set_visible(false)
		enemy_sprites[index].set_visible(false)
	enemy_count -= 1
	enemy_count_label.text = str(enemy_count)


#the value dictionary should be enemy titles matched to how many of that enemy
func set_upcoming_wave(value: Dictionary[String, int]) -> void:
	enemy_count = 0
	var frame_count: int = 0
	enemy_names = []
	var wave: Dictionary = {}
	for key: String in value:
		var new_enemy: Enemy
		for enemy: Enemy in player.game_manager.level.enemy_pool:
			if enemy.title == key:
				new_enemy = enemy
		wave[new_enemy] = value[key]
		enemy_count += value[key]
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
	enemy_count_label.text = str(enemy_count)


func set_currency_count(value: int) -> void:
	currency_count.text = str(value)


func set_energy_amount(value: int) -> void:
	energy_label.text = str(value)


func set_crosshair_visible(value: bool) -> void:
	crosshair.set_visible(value)


@warning_ignore("unused_parameter")
func set_weapon_energy(value: int, energy_type: Data.EnergyType) -> void:
	if value == 0:
		player.zeropower_audio.play()
	if value == 100:
		player.fullpower_audio.play()


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
	var string_array: PackedStringArray = text.split("%")
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
				output.append("[img=32]%s[/img]" % KeyIconMap.keys[str(event.physical_keycode)])
			if event is InputEventMouseButton:
				output.append("[img=32]%s[/img]" % KeyIconMap.mouse_buttons[str(event.button_index)])
		string_array[1] = "".join(output)
	text = "".join(string_array)
	return text
