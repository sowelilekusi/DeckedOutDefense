extends CanvasLayer
class_name HUD

var last_lives_count = 120
@export var wave_count : Label
@export var lives_count : Label
@export var currency_count : Label
@export var minimap_outline : TextureRect
@export var crosshair : Control
@export var minimap : TextureRect
@export var minimap_cam : MinimapCamera3D
@export var minimap_viewport : SubViewport
@export var fps_label : Label
@export var hover_text : Label
var minimap_anchor : Node3D
var enemy_names = []
@export var enemy_sprites : Array[TextureRect]
@export var enemy_counts : Array[Label]
@export var weapon_energy_bar : TextureProgressBar
@export var offhand_energy_bar : TextureProgressBar
@export var pickup_notif_scene : PackedScene
@export var wave_start_label : Label

var wave_start_label_shrinking := false
var wave_start_label_growing := false
var wave_start_label_ease_time := 1.0
var wave_start_label_ease_progress := 0.0


func set_energy_visible(value):
	weapon_energy_bar.set_visible(value)


func set_offhand_energy_visible(value):
	offhand_energy_bar.set_visible(value)


func ease_in_out_quart(x : float) -> float:
	return 8.0 * x * x * x * x if x < 0.5 else 1 - pow(-2.0 * x + 2.0, 4) / 2.0


func _process(delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	
	wave_start_label.text = "Press [" + Data.player_keymap.ready.as_text_key_label() + "] to start wave"
	if wave_start_label_growing or wave_start_label_shrinking:
		wave_start_label_ease_progress += delta
		if wave_start_label_growing:
			wave_start_label.set_visible(true)
			wave_start_label.offset_left = lerp(0.0, -300.0, ease_in_out_quart(wave_start_label_ease_progress / wave_start_label_ease_time))
			wave_start_label.offset_right = lerp(0.0, 300.0, ease_in_out_quart(wave_start_label_ease_progress / wave_start_label_ease_time))
			if wave_start_label_ease_progress >= wave_start_label_ease_time:
				wave_start_label_growing = false
				wave_start_label_ease_progress = 0.0
		elif wave_start_label_shrinking:
			wave_start_label.offset_left = lerp(-300.0, 0.0, ease_in_out_quart(wave_start_label_ease_progress / wave_start_label_ease_time))
			wave_start_label.offset_right = lerp(300.0, 0.0, ease_in_out_quart(wave_start_label_ease_progress / wave_start_label_ease_time))
			if wave_start_label_ease_progress >= wave_start_label_ease_time:
				wave_start_label.set_visible(false)
				wave_start_label_shrinking = false
				wave_start_label_ease_progress = 0.0


func grow_wave_start_label():
	wave_start_label_growing = true
	wave_start_label_shrinking = false


func shrink_wave_start_label():
	wave_start_label_shrinking = true
	wave_start_label_growing = false


func set_hover_text(text):
	hover_text.text = text
	hover_text.set_visible(true)


func unset_hover_text():
	hover_text.set_visible(false)


func set_wave_count(value):
	wave_count.text = str(value)


func set_lives_count(value):
	lives_count.text = str(value)
	for x in last_lives_count - value:
		$LivesBar.take_life()
	last_lives_count = value


func enemy_count_down(enemy):
	var index = enemy_names.find(enemy.title)
	var num = enemy_counts[index].text.to_int() - 1
	enemy_counts[index].text = str(num)
	if num == 0:
		enemy_counts[index].set_visible(false)
		enemy_sprites[index].set_visible(false)


func set_upcoming_wave(value):
	var frame_count = 0
	enemy_names = []
	var wave = {}
	for index in value:
		wave[Data.enemies[index]] = value[index]
	for x in enemy_sprites.size():
		enemy_sprites[x].set_visible(false)
		enemy_counts[x].set_visible(false)
	for enemy in wave:
		enemy_names.append(enemy.title)
		enemy_sprites[frame_count].texture = enemy.icon
		enemy_counts[frame_count].text = str(wave[enemy])
		enemy_sprites[frame_count].set_visible(true)
		enemy_counts[frame_count].set_visible(true)
		frame_count += 1


func set_currency_count(value):
	currency_count.text = str(value)


func set_crosshair_visible(value : bool):
	crosshair.set_visible(value)


func set_weapon_energy(value):
	weapon_energy_bar.value = value


func set_offhand_energy(value):
	offhand_energy_bar.value = value


func maximise_minimap(anchor):
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


func minimize_minimap(anchor):
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
	var notif = pickup_notif_scene.instantiate()
	notif.set_card(card)
	$VBoxContainer.add_child(notif)
