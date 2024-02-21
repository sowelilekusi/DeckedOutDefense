class_name PickupNotification extends PanelContainer

@export var fade_out_time: float
@export var style: StyleBoxFlat
@export var text_style: Color
@export var common_background: Color
@export var uncommon_background: Color
@export var rare_background: Color
@export var epic_background: Color
@export var legendary_background: Color

var fade_time: float = 0.0
var fading: bool = false


func _ready() -> void:
	add_theme_stylebox_override("panel", style)
	$HBoxContainer/Label.add_theme_color_override("font_color", text_style)
	$HBoxContainer/Label2.add_theme_color_override("font_color", text_style)
	$Timer.start()


func _process(delta: float) -> void:
	if fading:
		fade_time += delta
		style.bg_color.a = lerp(200.0 / 255.0, 0.0, fade_time / fade_out_time)
		text_style.a = lerp(220.0 / 255.0, 0.0, fade_time / fade_out_time)
		$HBoxContainer/Label.add_theme_color_override("font_color", text_style)
		$HBoxContainer/Label2.add_theme_color_override("font_color", text_style)
		if fade_time >= fade_out_time:
			queue_free()


func set_card(card: Card) -> void:
	$HBoxContainer/Label.text = card.display_name
	match(card.rarity):
		Data.Rarity.COMMON:
			style.bg_color = common_background
		Data.Rarity.UNCOMMON:
			style.bg_color = uncommon_background
		Data.Rarity.RARE:
			style.bg_color = rare_background
		Data.Rarity.EPIC:
			style.bg_color = epic_background
		Data.Rarity.LEGENDARY:
			style.bg_color = legendary_background


func _on_timer_timeout() -> void:
	fading = true
