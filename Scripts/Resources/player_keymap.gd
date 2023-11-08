extends Resource
class_name PlayerKeymap

const SAVE_PATH := "user://keymap.tres"

@export var title : String

@export var move_forward : InputEventKey
@export var move_backward : InputEventKey
@export var move_left : InputEventKey
@export var move_right : InputEventKey
@export var jump : InputEventKey
@export var sprint : InputEventKey
@export var interact : InputEventKey
@export var open_text_chat : InputEventKey
@export var ready : InputEventKey
@export var pause : InputEventKey
@export var equip_card_in_gauntlet : InputEventKey
@export var view_map : InputEventKey


func apply():
	replace_action_event("Move Forward", move_forward)
	replace_action_event("Move Backward", move_backward)
	replace_action_event("Move Left", move_left)
	replace_action_event("Move Right", move_right)
	replace_action_event("Jump", jump)
	replace_action_event("Sprint", sprint)
	replace_action_event("Interact", interact)
	replace_action_event("Open Text Chat", open_text_chat)
	replace_action_event("Ready", ready)
	replace_action_event("Pause", pause)
	replace_action_event("Equip In Gauntlet", equip_card_in_gauntlet)
	replace_action_event("View Map", view_map)


func replace_action_event(action_string, event):
	InputMap.action_erase_events(action_string)
	InputMap.action_add_event(action_string, event)


func get_current_input_map():
	move_forward = InputMap.action_get_events("Move Forward")[0]
	move_backward = InputMap.action_get_events("Move Backward")[0]
	move_left = InputMap.action_get_events("Move Left")[0]
	move_right = InputMap.action_get_events("Move Right")[0]
	jump = InputMap.action_get_events("Jump")[0]
	sprint = InputMap.action_get_events("Sprint")[0]
	interact = InputMap.action_get_events("Interact")[0]
	open_text_chat = InputMap.action_get_events("Open Text Chat")[0]
	ready = InputMap.action_get_events("Ready")[0]
	pause = InputMap.action_get_events("Pause")[0]
	equip_card_in_gauntlet = InputMap.action_get_events("Equip In Gauntlet")[0]
	view_map = InputMap.action_get_events("View Map")[0]


func save_profile_to_disk():
	get_current_input_map()
	ResourceSaver.save(self, SAVE_PATH)
static func load_profile_from_disk() -> PlayerKeymap:
	if ResourceLoader.exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH)
	return Data.keymaps[0]
