class_name CardInHand extends Node2D

var stats: Card
@export var rarity_sprite: Sprite2D
@export var title_text: Label
@export var description: RichTextLabel
@export var target_label: Label


func set_card(value: Card) -> void:
	stats = value
	title_text.text = stats.display_name
	target_label.text = str(Data.TargetType.keys()[stats.tower_stats.target_type])
	rarity_sprite.region_rect = Rect2(64 * stats.rarity, 0, 64, 64)


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
