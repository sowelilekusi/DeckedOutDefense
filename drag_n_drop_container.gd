class_name DragNDropContainer
extends MarginContainer

signal dropped(dropped_node: Control, dropped_from: DragNDropContainer)

@export var panel: PanelContainer
@export var panel_label: Label
@export var finite_contents: bool = true
@export var contents: Control
@export var drag_parent: Node

var dragging: bool = false
var drag_node: Control


func _ready() -> void:
	if contents:
		panel.move_to_front()
		panel.visible = false


func _process(_delta: float) -> void:
	if dragging:
		drag_node.position = get_viewport().get_mouse_position()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed == true and event.button_index == 1:
			start_drag()
		if event.pressed == false and event.button_index == 1:
			end_drag()


func set_label(text: String) -> void:
	panel_label.text = text


func set_immutable_contents(new_contents: Control) -> void:
	if contents:
		remove_child(contents)
		contents = null
	finite_contents = false
	contents = new_contents.duplicate()
	add_child(contents)
	panel.move_to_front()
	panel.visible = false


func add_contents(new_contents: Control) -> void:
	if finite_contents:
		remove_contents()
		contents = new_contents.duplicate()
		add_child(contents)
		panel.move_to_front()
		panel.visible = false


func remove_contents() -> void:
	if finite_contents:
		remove_child(contents)
		contents = null
		panel.visible = true


func start_drag() -> void:
	if !contents:
		return
	drag_node = contents.duplicate()
	drag_parent.add_child(drag_node)
	drag_node.size = Vector2.ZERO
	drag_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.visible = true
	panel_label.visible = false
	dragging = true


func end_drag() -> void:
	if !contents:
		return
	panel.visible = false
	dragging = false
	dropped.emit(drag_node, self)
	drag_node.queue_free()
