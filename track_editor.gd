class_name TrackEditor
extends Control

signal cards_remixed(cards_consumed: Array[Card], cards_created: Array[Card], amount_spent: int)

@export var drag_feature: FeatureUI
@export var sample_library: VBoxContainer
@export var feature_scene: PackedScene
@export var tower_parts: HBoxContainer
@export var weapon_parts: HBoxContainer
@export var drop_down: OptionButton
@export var card_desc: CardDescriptionUI
@export var check_button: CheckButton
@export var price_panel_scene: PackedScene
@export var price_label: Label

const FEATURE_SLOTS: int = 6

var hero: Hero
var dragging: bool = false
var hovered_feature: Feature
var hovered_drop_slot: int = -2
var hovered_drop_track: int = 0
var tower_feature_uis: Array[FeatureUI]
var weapon_feature_uis: Array[FeatureUI]
var features_list: Array[Feature]
var tower_slots: Array[MarginContainer]
var weapon_slots: Array[MarginContainer]
var tower_prices: Array[PricePanel]
var weapon_prices: Array[PricePanel]
var cards: Array[Card]
var card_selected: Card
var temp_card: Card
var cost: int = 0


func _ready() -> void:
	#populate_sample_library()
	#populate_feature_slots()
	card_desc.hide_features()
	tower_parts.mouse_entered.connect(set_hovered_drop_slot.bind(-1, 0))
	weapon_parts.mouse_entered.connect(set_hovered_drop_slot.bind(-1, 1))
	tower_parts.mouse_exited.connect(unset_hovered_drop_slot)
	weapon_parts.mouse_exited.connect(unset_hovered_drop_slot)
	price_label.text = "$" + str(cost)


func _process(_delta: float) -> void:
	drag_feature.position = get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("Pause"):
		_on_cancel_button_pressed()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed == true and event.button_index == 1:
			if hovered_feature != null:
				attach_feat_to_mouse(hovered_feature)
		if event.pressed == false and event.button_index == 1:
			detach_feat_from_mouse()


func select_card(option: int) -> void:
	for feature_ui: FeatureUI in tower_feature_uis:
		feature_ui.queue_free()
	tower_feature_uis = []
	for feature_ui: FeatureUI in weapon_feature_uis:
		feature_ui.queue_free()
	weapon_feature_uis = []
	card_selected = cards[option]
	temp_card = card_selected.duplicate()
	temp_card.tower_stats = temp_card.tower_stats.get_duplicate()
	temp_card.weapon_stats = temp_card.weapon_stats.get_duplicate()
	card_desc.set_card(temp_card, check_button.button_pressed)
	for feature: Feature in temp_card.tower_stats.features:
		add_feature(feature, 0, false)
	for feature: Feature in temp_card.weapon_stats.features:
		add_feature(feature, 1, false)


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
		feat.show_title()
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
		var vbox: MarginContainer = MarginContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.mouse_filter = Control.MOUSE_FILTER_STOP
		vbox.mouse_entered.connect(set_hovered_drop_slot.bind(tower_slots.size(), 0))
		vbox.mouse_exited.connect(unset_hovered_drop_slot)
		tower_parts.add_child(vbox)
		tower_slots.append(vbox)
		if x != 0:
			var panel: PricePanel = price_panel_scene.instantiate() as PricePanel
			panel.set_price(Data.slot_prices[x - 1])
			vbox.add_child(panel)
			tower_prices.append(panel)
	for x: int in FEATURE_SLOTS:
		var vbox: MarginContainer = MarginContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.mouse_filter = Control.MOUSE_FILTER_STOP
		vbox.mouse_entered.connect(set_hovered_drop_slot.bind(weapon_slots.size(), 1))
		vbox.mouse_exited.connect(unset_hovered_drop_slot)
		weapon_parts.add_child(vbox)
		weapon_slots.append(vbox)
		if x != 0:
			var panel: PricePanel = price_panel_scene.instantiate() as PricePanel
			panel.set_price(Data.slot_prices[x - 1])
			vbox.add_child(panel)
			weapon_prices.append(panel)


func add_feature(feature: Feature, track: int, modify_resource: bool = true) -> void:
	if hovered_drop_slot == 0:
		return
	if track == 0:
		if hovered_drop_slot > 0 and hovered_drop_slot < tower_feature_uis.size():
			change_feature(tower_feature_uis[hovered_drop_slot], feature, 0)
		elif tower_feature_uis.size() < FEATURE_SLOTS:
			var feature_visual: FeatureUI = feature_scene.instantiate()
			feature_visual.set_feature(feature)
			tower_slots[tower_feature_uis.size()].add_child(feature_visual)
			tower_feature_uis.append(feature_visual)
			if modify_resource:
				temp_card.tower_stats.features.append(feature)
				tower_prices[tower_feature_uis.size() - 2].visible = false
				cost += Data.slot_prices[tower_feature_uis.size() - 2]
				price_label.text = "$" + str(cost)
				card_desc.set_card(temp_card, check_button.button_pressed)
				if cost > hero.currency:
					$PanelContainer/VBoxContainer/InfoPanel/VBoxContainer2/Controls/ConfirmButton.disabled = true
	elif track == 1:
		if hovered_drop_slot > 0 and hovered_drop_slot < weapon_feature_uis.size():
			change_feature(weapon_feature_uis[hovered_drop_slot], feature, 1)
		elif weapon_feature_uis.size() < FEATURE_SLOTS:
			var feature_visual: FeatureUI = feature_scene.instantiate()
			feature_visual.set_feature(feature)
			weapon_slots[weapon_feature_uis.size()].add_child(feature_visual)
			weapon_feature_uis.append(feature_visual)
			if modify_resource:
				temp_card.weapon_stats.features.append(feature)
				weapon_prices[weapon_feature_uis.size() - 2].visible = false
				cost += Data.slot_prices[weapon_feature_uis.size() - 2]
				price_label.text = "$" + str(cost)
				card_desc.set_card(temp_card, check_button.button_pressed)
				if cost > hero.currency:
					$PanelContainer/VBoxContainer/InfoPanel/VBoxContainer2/Controls/ConfirmButton.disabled = true


func change_feature(existing_feature: FeatureUI, new_feature: Feature, track: int) -> void:
	existing_feature.set_feature(new_feature)
	if track == 0:
		var i: int = tower_feature_uis.find(existing_feature)
		temp_card.tower_stats.features[i] = new_feature
	elif track == 1:
		var i: int = weapon_feature_uis.find(existing_feature)
		temp_card.weapon_stats.features[i] = new_feature
	card_desc.set_card(temp_card, check_button.button_pressed)


func attach_feat_to_mouse(feature: Feature) -> void:
	drag_feature.set_feature(feature)
	drag_feature.visible = true
	dragging = true


func detach_feat_from_mouse() -> void:
	drag_feature.visible = false
	if hovered_drop_slot >= -1 and dragging == true:
		add_feature(drag_feature.feature, hovered_drop_track)
	dragging = false


func set_hovered_feature(feature: Feature) -> void:
	hovered_feature = feature


func unset_hovered_feature() -> void:
	hovered_feature = null


func set_hovered_drop_slot(slot: int = -2, track: int = 0) -> void:
	hovered_drop_slot = slot
	hovered_drop_track = track


func unset_hovered_drop_slot() -> void:
	hovered_drop_slot = -2
	hovered_drop_track = -1


func _on_cancel_button_pressed() -> void:
	var cards_to_remove: Array[Card] = []
	var cards_to_add: Array[Card] = []
	cards_remixed.emit(cards_to_remove, cards_to_add, 0)
	queue_free()


func _on_confirm_button_pressed() -> void:
	var cards_to_remove: Array[Card] = []
	var cards_to_add: Array[Card] = []
	cards_to_remove.append(card_selected)
	cards_to_add.append(temp_card)
	cards_remixed.emit(cards_to_remove, cards_to_add, cost)
	queue_free()


func _on_check_button_toggled(toggled_on: bool) -> void:
	card_desc.set_card(temp_card, toggled_on)
