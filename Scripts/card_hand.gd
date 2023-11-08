extends Node2D
class_name CardInHand

var stats : Card
@export var rarity_sprite : Sprite2D
@export var title_text: Label
@export var damage_text_text: Label
@export var damage_text: Label
@export var fire_rate_text_text: Label
@export var fire_rate_text: Label
@export var range_text_text: Label
@export var range_text: Label

func set_card(value):
	stats = value
	title_text.text = stats.title
	rarity_sprite.region_rect = Rect2(64 * stats.rarity, 0, 64, 64)
	view_weapon()


func view_weapon():
	damage_text.text = str(stats.weapon_stats.damage)
	fire_rate_text.text = str(stats.weapon_stats.fire_rate)
	range_text.text = str(stats.weapon_stats.fire_rate)


func view_tower():
	damage_text.text = str(stats.tower_stats.damage)
	fire_rate_text.text = str(stats.tower_stats.fire_rate)
	range_text.text = str(stats.tower_stats.fire_rate)
