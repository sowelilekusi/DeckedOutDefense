class_name PickupNotification
extends PanelContainer

@export var fade_out_time: float
@export var text_style: Color
@export var common_background: Color
@export var uncommon_background: Color
@export var rare_background: Color
@export var epic_background: Color
@export var legendary_background: Color

var fade_time: float = 0.0
var fading: bool = false


func _ready() -> void:
	$Timer.start()


func _process(delta: float) -> void:
	if fading:
		fade_time += delta
		var mod_color: Color = Color.WHITE
		mod_color.a = 1.0 - (fade_time / fade_out_time)
		modulate = mod_color
		#$HBoxContainer/Label.add_theme_color_override("font_color", text_style)
		#$HBoxContainer/Label2.add_theme_color_override("font_color", text_style)
		if fade_time >= fade_out_time:
			queue_free()


func set_card(card: Card) -> void:
	$HBoxContainer/Label.text = tr(card.display_name)
	match(card.rarity):
		Data.Rarity.COMMON:
			$HBoxContainer/Label.add_theme_color_override("font_color", common_background)
		Data.Rarity.UNCOMMON:
			$HBoxContainer/Label.add_theme_color_override("font_color", uncommon_background)
		Data.Rarity.RARE:
			$HBoxContainer/Label.add_theme_color_override("font_color", rare_background)
		Data.Rarity.EPIC:
			$HBoxContainer/Label.add_theme_color_override("font_color", epic_background)
		Data.Rarity.LEGENDARY:
			$HBoxContainer/Label.add_theme_color_override("font_color", legendary_background)


func _on_timer_timeout() -> void:
	fading = true
