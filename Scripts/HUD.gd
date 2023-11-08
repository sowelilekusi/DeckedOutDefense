extends CanvasLayer
class_name HUD

var last_lives_count = 120
@export var wave_count : Label
@export var lives_count : Label
@export var enemy_count : Label
@export var currency_count : Label
@export var crosshair : TextureRect
@export var minimap : TextureRect
@export var minimap_cam : MinimapCamera3D
@export var minimap_viewport : SubViewport
@export var fps_label : Label
var minimap_anchor : Node3D
@export var enemy_sprites : Array[TextureRect]
@export var enemy_counts : Array[Label]


func _process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())


func set_wave_count(value):
	wave_count.text = str(value)


func set_lives_count(value):
	lives_count.text = str(value)
	for x in last_lives_count - value:
		$LivesBar.take_life()
	last_lives_count = value


func set_enemy_count(value):
	enemy_count.text = "Enemies Remaining: " + str(value)


func set_upcoming_wave(value):
	var frame_count = 0
	for x in enemy_sprites.size():
		enemy_sprites[x].set_visible(false)
		enemy_counts[x].set_visible(false)
	for enemy in value:
		enemy_sprites[frame_count].texture = enemy.icon
		enemy_counts[frame_count].text = str(value[enemy])
		enemy_sprites[frame_count].set_visible(true)
		enemy_counts[frame_count].set_visible(true)
		frame_count += 1


func set_currency_count(value):
	currency_count.text = str(value)


func set_crosshair_visible(value : bool):
	crosshair.set_visible(value)


func maximise_minimap(anchor):
	minimap_cam.anchor = anchor
	minimap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	minimap.offset_bottom = -40
	minimap.offset_top = 40
	minimap.offset_left = 40
	minimap.offset_right = -40
	minimap_viewport.size = Vector2(1840, 1000)
	minimap_cam.size = 30


func minimize_minimap(anchor):
	minimap_cam.anchor = anchor
	minimap.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	minimap.offset_right = -40
	minimap.offset_top = 40
	minimap.offset_left = -256
	minimap.offset_bottom = 256
	minimap_viewport.size = Vector2(256, 256)
	minimap_cam.size = 15
