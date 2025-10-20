class_name TrackEditor
extends Control

@export var drag_feature: FeatureUI
@export var sample_library: VBoxContainer
@export var feature_scene: PackedScene
@export var features_list: Array[Feature]
@export var parts: HBoxContainer

var dragging: bool = false
var hovered_feature: Feature
var hovered_drop_slot: int = -2
var feature_uis: Array[FeatureUI]
var slots: Array[VBoxContainer]

const FEATURE_SLOTS: int = 6


func _ready() -> void:
	populate_sample_library()
	populate_feature_slots()
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


func populate_sample_library() -> void:
	for x: int in 3:
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		for y: int in 3:
			var feat: FeatureUI = feature_scene.instantiate() as FeatureUI
			feat.set_feature(features_list[x])
			feat.mouse_filter = Control.MOUSE_FILTER_PASS
			feat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			feat.mouse_entered.connect(set_hovered_feature.bind(feat.feature))
			hbox.add_child(feat)
		sample_library.add_child(hbox)
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


func add_feature(feature: Feature) -> void:
	if hovered_drop_slot >= 0 and hovered_drop_slot < feature_uis.size():
		change_feature(feature_uis[hovered_drop_slot], feature)
	elif feature_uis.size() < FEATURE_SLOTS:
		var feature_visual: FeatureUI = feature_scene.instantiate()
		feature_visual.set_feature(feature)
		slots[feature_uis.size()].add_child(feature_visual)
		feature_uis.append(feature_visual)


func change_feature(existing_feature: FeatureUI, new_feature: Feature) -> void:
	existing_feature.set_feature(new_feature)


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
	queue_free()


func _on_confirm_button_pressed() -> void:
	pass # Replace with function body.
