extends PanelContainer


var hovered_slot: DragNDropContainer

@export var slots: Array[DragNDropContainer]
@export var other_slots: Array[DragNDropContainer]
@export var features: Array[Feature]
@export var feature_ui: PackedScene


func _ready() -> void:
	for slot: DragNDropContainer in slots:
		slot.mouse_entered.connect(hover_slot.bind(slot))
		slot.mouse_exited.connect(unhover_slot)
		slot.dropped.connect(drop_slot)
	var x: int = 0
	for slot: DragNDropContainer in other_slots:
		var new_feature_ui: FeatureUI = feature_ui.instantiate() as FeatureUI
		new_feature_ui.set_feature(features[x])
		slot.set_immutable_contents(new_feature_ui)
		slot.mouse_entered.connect(hover_slot.bind(slot))
		slot.mouse_exited.connect(unhover_slot)
		slot.dropped.connect(drop_slot)
		x += 1


func drop_slot(dropped_ui: Control, from: DragNDropContainer) -> void:
	if hovered_slot:
		from.remove_contents()
		hovered_slot.add_contents(dropped_ui)


func hover_slot(slot: DragNDropContainer) -> void:
	hovered_slot = slot


func unhover_slot() -> void:
	hovered_slot = null
