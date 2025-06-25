class_name CardInHand
extends Node2D

var stats: Card
@export var rarity_sprite: Sprite2D
@export var title_text: Label
@export var description: RichTextLabel
@export var target_label: Label
@export var energy_cost: Label
@export var duration: Label


func set_card(value: Card) -> void:
	stats = value
	title_text.text = stats.display_name
	target_label.text = str(Data.TargetType.keys()[stats.tower_stats.target_type])
	rarity_sprite.region_rect = Rect2(64 * stats.rarity, 0, 64, 64)
	if stats.rarity == Data.Rarity.COMMON:
		energy_cost.text = "1"
	if stats.rarity == Data.Rarity.UNCOMMON:
		energy_cost.text = "2"
	if stats.rarity == Data.Rarity.RARE:
		energy_cost.text = "3"
	if stats.rarity == Data.Rarity.EPIC:
		energy_cost.text = "4"
	if stats.rarity == Data.Rarity.LEGENDARY:
		energy_cost.text = "5"
	duration.text = str(value.duration)


func process_card_text(card_text: CardText) -> String:
	var processed_string: String = card_text.text
	for stat: StatAttribute in card_text.attributes:
		processed_string = processed_string.replace(stat.key, str(stat.value))
	processed_string = processed_string.replace("/", "[color=red]")
	processed_string = processed_string.replace("\\", "[color=black]")
	return processed_string


func view_weapon() -> void:
	description.text = process_card_text(stats.weapon_stats)
	target_label.text = "Both"


func view_tower() -> void:
	description.text = process_card_text(stats.tower_stats)
	target_label.text = str(Data.TargetType.keys()[stats.tower_stats.target_type])
