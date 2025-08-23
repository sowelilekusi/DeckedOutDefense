class_name CardDescriptionUI
extends VBoxContainer

@export var card_name_label: Label
@export var card_description_label: RichTextLabel
@export var feature_list: VBoxContainer
@export var feature_scene: PackedScene
@export var target_list: VBoxContainer

var card: Card
var side_a: bool


func show_card_name() -> void:
	card_name_label.visible = true


func hide_card_name() -> void:
	card_name_label.visible = false


func set_card(new_card: Card, side: bool) -> void:
	card = new_card
	side_a = side
	card_name_label.text = tr(card.display_name)
	card_description_label.text = process_card_text(card.tower_stats.tower_features_applied()) if side_a else process_card_text(card.weapon_stats.weapon_features_applied())
	populate_features()
	populate_targets()


func populate_features() -> void:
	for child: Node in feature_list.get_children():
		child.queue_free()
	var card_text: CardText = card.tower_stats if side_a else card.weapon_stats
	for feature: Feature in card_text.features:
		var ui: FeatureUI = feature_scene.instantiate()
		ui.set_feature(feature)
		feature_list.add_child(ui)


func populate_targets() -> void:
	for child: Node in target_list.get_children():
		child.queue_free()
	if !side_a:
		var label: Label = Label.new()
		label.text = tr("TARGET_ALL")
		target_list.add_child(label)
	else:
		for target: Data.TargetType in card.tower_stats.tower_features_applied().target_type:
			var label: Label = Label.new()
			label.text = tr(Data.target_type_names[target])
			target_list.add_child(label)


func process_card_text(card_text: CardText) -> String:
	var processed_string: String = tr(card_text.text)
	for key: String in card_text.attributes:
		processed_string = processed_string.replace(key, "[color=red]" + str(card_text.attributes[key]) + "[color=white]")
	processed_string = processed_string.replace("%", "")
	return processed_string
