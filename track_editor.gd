class_name TrackEditor
extends Control

signal cards_remixed(cards_consumed: Array[Card], cards_created: Array[Card])

@export var drag_feature: FeatureUI
@export var sample_library: VBoxContainer
@export var feature_scene: PackedScene
@export var parts: HBoxContainer
@export var drop_down: OptionButton
@export var card_desc: CardDescriptionUI

const FEATURE_SLOTS: int = 6

var dragging: bool = false
var hovered_feature: Feature
var hovered_drop_slot: int = -2
var feature_uis: Array[FeatureUI]
var features_list: Array[Feature]
var slots: Array[VBoxContainer]
var cards: Array[Card]
var card_selected: Card
var temp_card: Card


func _ready() -> void:
	#populate_sample_library()
	#populate_feature_slots()
	card_desc.hide_features()
	parts.mouse_entered.connect(set_hovered_drop_slot.bind(-1))
	parts.mouse_exited.connect(unset_hovered_drop_slot)


func _process(_delta: float) -> void:
	drag_feature.position = get_viewport().get_mouse_position()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed == true and event.button_index == 1:
			if hovered_feature != null:
				attach_feat_to_mouse(hovered_feature)
		if event.pressed == false and event.button_index == 1:
			detach_feat_from_mouse()


func select_card(option: int) -> void:
	for feature_ui: FeatureUI in feature_uis:
		feature_ui.queue_free()
	feature_uis = []
	card_selected = cards[option]
	temp_card = card_selected.duplicate()
	temp_card.tower_stats = temp_card.tower_stats.get_duplicate()
	temp_card.weapon_stats = temp_card.weapon_stats.get_duplicate()
	card_desc.set_card(temp_card, true)
	for feature: Feature in temp_card.tower_stats.features:
		add_feature(feature, false)


func add_option(card_options: Array[Card]) -> void:
	cards = card_options
	for card: Card in cards:
		drop_down.add_item(tr(card.display_name))
	drop_down.select(0)
	select_card(0)
	populate_sample_library()


func populate_sample_library() -> void:
	for card: Card in cards:
		for feature: Feature in card.tower_stats.features:
			if !features_list.has(feature):
				features_list.append(feature)
		for feature: Feature in card.weapon_stats.features:
			if !features_list.has(feature):
				features_list.append(feature)
	var i: int = 0
	var hbox: HBoxContainer
	for feature: Feature in features_list:
		if i == 0:
			hbox = HBoxContainer.new()
			sample_library.add_child(hbox)
		var feat: FeatureUI = feature_scene.instantiate() as FeatureUI
		feat.set_feature(feature)
		feat.mouse_filter = Control.MOUSE_FILTER_PASS
		feat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		feat.mouse_entered.connect(set_hovered_feature.bind(feat.feature))
		hbox.add_child(feat)
		i += 1
		if i == 3:
			i = 0
	sample_library.mouse_exited.connect(unset_hovered_feature)


func populate_feature_slots() -> void:
	for x: int in FEATURE_SLOTS:
		var vbox: VBoxContainer = VBoxContainer.new()
		var label: Label = Label.new()
		match slots.size():
			0: label.text = tr("SLOT_FIRST")
			1: label.text = tr("SLOT_SECOND")
			2: label.text = tr("SLOT_THIRD")
			3: label.text = tr("SLOT_FOURTH")
			4: label.text = tr("SLOT_FIFTH")
			5: label.text = tr("SLOT_SIXTH")
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		vbox.add_child(label)
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.mouse_filter = Control.MOUSE_FILTER_STOP
		vbox.mouse_entered.connect(set_hovered_drop_slot.bind(slots.size()))
		vbox.mouse_exited.connect(unset_hovered_drop_slot)
		parts.add_child(vbox)
		slots.append(vbox)


func add_feature(feature: Feature, modify_resource: bool = true) -> void:
	if hovered_drop_slot >= 0 and hovered_drop_slot < feature_uis.size():
		change_feature(feature_uis[hovered_drop_slot], feature)
	elif feature_uis.size() < FEATURE_SLOTS:
		var feature_visual: FeatureUI = feature_scene.instantiate()
		feature_visual.set_feature(feature)
		slots[feature_uis.size()].add_child(feature_visual)
		feature_uis.append(feature_visual)
		if modify_resource:
			temp_card.tower_stats.features.append(feature)
			card_desc.set_card(temp_card, true)


func change_feature(existing_feature: FeatureUI, new_feature: Feature) -> void:
	existing_feature.set_feature(new_feature)
	var i: int = feature_uis.find(existing_feature)
	temp_card.tower_stats.features[i] = new_feature
	card_desc.set_card(temp_card, true)


func attach_feat_to_mouse(feature: Feature) -> void:
	drag_feature.set_feature(feature)
	drag_feature.visible = true
	dragging = true


func detach_feat_from_mouse() -> void:
	drag_feature.visible = false
	if hovered_drop_slot >= -1 and dragging == true:
		add_feature(drag_feature.feature)
	dragging = false


func set_hovered_feature(feature: Feature) -> void:
	hovered_feature = feature


func unset_hovered_feature() -> void:
	hovered_feature = null


func set_hovered_drop_slot(slot: int = -2) -> void:
	hovered_drop_slot = slot


func unset_hovered_drop_slot() -> void:
	hovered_drop_slot = -2


func _on_cancel_button_pressed() -> void:
	var cards_to_remove: Array[Card] = []
	var cards_to_add: Array[Card] = []
	cards_remixed.emit(cards_to_remove, cards_to_add)
	queue_free()


func _on_confirm_button_pressed() -> void:
	var cards_to_remove: Array[Card] = []
	var cards_to_add: Array[Card] = []
	cards_to_remove.append(card_selected)
	cards_to_add.append(temp_card)
	cards_remixed.emit(cards_to_remove, cards_to_add)
	queue_free()
