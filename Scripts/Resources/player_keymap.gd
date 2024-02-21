class_name PlayerKeymap extends Resource

const SAVE_PATH: String = "user://keymap.tres"

@export var title: String

@export_category("Primary Bindings")
@export var move_forward: InputEvent
@export var move_backward: InputEvent
@export var move_left: InputEvent
@export var move_right: InputEvent
@export var jump: InputEvent
@export var sprint: InputEvent
@export var interact: InputEvent
@export var open_text_chat: InputEvent
@export var ready: InputEvent
@export var pause: InputEvent
@export var equip_card_in_gauntlet: InputEvent
@export var view_map: InputEvent
@export var fire1: InputEvent
@export var fire2: InputEvent
@export var select_next_card: InputEvent
@export var select_prev_card: InputEvent

@export_category("Secondary Bindings")
@export var secondary_move_forward: InputEvent
@export var secondary_move_backward: InputEvent
@export var secondary_move_left: InputEvent
@export var secondary_move_right: InputEvent
@export var secondary_jump: InputEvent
@export var secondary_sprint: InputEvent
@export var secondary_interact: InputEvent
@export var secondary_open_text_chat: InputEvent
@export var secondary_ready: InputEvent
@export var secondary_pause: InputEvent
@export var secondary_equip_card_in_gauntlet: InputEvent
@export var secondary_view_map: InputEvent
@export var secondary_fire1: InputEvent
@export var secondary_fire2: InputEvent
@export var secondary_select_next_card: InputEvent
@export var secondary_select_prev_card: InputEvent


func apply() -> void:
	replace_action_event("Move Forward", move_forward, secondary_move_forward)
	replace_action_event("Move Backward", move_backward, secondary_move_backward)
	replace_action_event("Move Left", move_left, secondary_move_left)
	replace_action_event("Move Right", move_right, secondary_move_right)
	replace_action_event("Jump", jump, secondary_jump)
	replace_action_event("Sprint", sprint, secondary_sprint)
	replace_action_event("Interact", interact, secondary_interact)
	replace_action_event("Open Text Chat", open_text_chat, secondary_open_text_chat)
	replace_action_event("Ready", ready, secondary_ready)
	replace_action_event("Pause", pause, secondary_pause)
	replace_action_event("Equip In Gauntlet", equip_card_in_gauntlet, secondary_equip_card_in_gauntlet)
	replace_action_event("View Map", view_map, secondary_view_map)
	replace_action_event("Primary Fire", fire1, secondary_fire1)
	replace_action_event("Secondary Fire", fire2, secondary_fire2)
	replace_action_event("Select Next Card", select_next_card, secondary_select_next_card)
	replace_action_event("Select Previous Card", select_prev_card, secondary_select_prev_card)


func replace_action_event(action_string: String, event: InputEvent, secondary_event: InputEvent) -> void:
	InputMap.action_erase_events(action_string)
	if event:
		InputMap.action_add_event(action_string, event)
	if secondary_event:
		InputMap.action_add_event(action_string, secondary_event)


func set_primary_action_event(action_string: String, event: InputEvent) -> void:
	var secondary_event: InputEvent
	if InputMap.action_get_events(action_string).size() > 1:
		secondary_event = InputMap.action_get_events(action_string)[1]
	replace_action_event(action_string, event, secondary_event)


func set_secondary_action_event(action_string: String, event: InputEvent) -> void:
	var primary_event: InputEvent
	if InputMap.action_get_events(action_string).size() > 0:
		primary_event = InputMap.action_get_events(action_string)[0]
	replace_action_event(action_string, primary_event, event)


func append_input_map() -> void:
	InputMap.action_add_event("Move Forward", move_forward)
	InputMap.action_add_event("Move Backward", move_backward)
	InputMap.action_add_event("Move Left", move_left)
	InputMap.action_add_event("Move Right", move_right)
	InputMap.action_add_event("Jump", jump)
	InputMap.action_add_event("Sprint", sprint)
	InputMap.action_add_event("Interact", interact)
	InputMap.action_add_event("Open Text Chat", open_text_chat)
	InputMap.action_add_event("Ready", ready)
	InputMap.action_add_event("Pause", pause)
	InputMap.action_add_event("Equip In Gauntlet", equip_card_in_gauntlet)
	InputMap.action_add_event("View Map", view_map)
	InputMap.action_add_event("Primary Fire", fire1)
	InputMap.action_add_event("Secondary Fire", fire2)
	InputMap.action_add_event("Select Next Card", select_next_card)
	InputMap.action_add_event("Select Previous Card", select_prev_card)


func get_current_input_map() -> void:
	move_forward = InputMap.action_get_events("Move Forward")[0]
	if InputMap.action_get_events("Move Forward").size() > 1:
		secondary_move_forward = InputMap.action_get_events("Move Forward")[1]
		
	move_backward = InputMap.action_get_events("Move Backward")[0]
	if InputMap.action_get_events("Move Backward").size() > 1:
		secondary_move_backward = InputMap.action_get_events("Move Backward")[1]
		
	move_left = InputMap.action_get_events("Move Left")[0]
	if InputMap.action_get_events("Move Left").size() > 1:
		secondary_move_left = InputMap.action_get_events("Move Left")[1]
		
	move_right = InputMap.action_get_events("Move Right")[0]
	if InputMap.action_get_events("Move Right").size() > 1:
		secondary_move_right = InputMap.action_get_events("Move Right")[1]
		
	jump = InputMap.action_get_events("Jump")[0]
	if InputMap.action_get_events("Jump").size() > 1:
		secondary_jump = InputMap.action_get_events("Jump")[1]
		
	sprint = InputMap.action_get_events("Sprint")[0]
	if InputMap.action_get_events("Sprint").size() > 1:
		secondary_sprint = InputMap.action_get_events("Sprint")[1]
		
	interact = InputMap.action_get_events("Interact")[0]
	if InputMap.action_get_events("Interact").size() > 1:
		secondary_interact = InputMap.action_get_events("Interact")[1]
		
	open_text_chat = InputMap.action_get_events("Open Text Chat")[0]
	if InputMap.action_get_events("Open Text Chat").size() > 1:
		secondary_open_text_chat = InputMap.action_get_events("Open Text Chat")[1]
		
	ready = InputMap.action_get_events("Ready")[0]
	if InputMap.action_get_events("Ready").size() > 1:
		secondary_ready = InputMap.action_get_events("Ready")[1]
		
	pause = InputMap.action_get_events("Pause")[0]
	if InputMap.action_get_events("Pause").size() > 1:
		secondary_pause = InputMap.action_get_events("Pause")[1]
		
	equip_card_in_gauntlet = InputMap.action_get_events("Equip In Gauntlet")[0]
	if InputMap.action_get_events("Equip In Gauntlet").size() > 1:
		secondary_equip_card_in_gauntlet = InputMap.action_get_events("Equip In Gauntlet")[1]
		
	view_map = InputMap.action_get_events("View Map")[0]
	if InputMap.action_get_events("View Map").size() > 1:
		secondary_view_map = InputMap.action_get_events("View Map")[1]
		
	fire1 = InputMap.action_get_events("Primary Fire")[0]
	if InputMap.action_get_events("Primary Fire").size() > 1:
		secondary_fire1 = InputMap.action_get_events("Primary Fire")[1]
		
	fire2 = InputMap.action_get_events("Secondary Fire")[0]
	if InputMap.action_get_events("Secondary Fire").size() > 1:
		secondary_fire2 = InputMap.action_get_events("Secondary Fire")[1]
		
	select_next_card = InputMap.action_get_events("Select Next Card")[0]
	if InputMap.action_get_events("Select Next Card").size() > 1:
		secondary_select_next_card = InputMap.action_get_events("Select Next Card")[1]
		
	select_prev_card = InputMap.action_get_events("Select Previous Card")[0]
	if InputMap.action_get_events("Select Previous Card").size() > 1:
		secondary_select_prev_card = InputMap.action_get_events("Select Previous Card")[1]


func save_profile_to_disk() -> void:
	get_current_input_map()
	ResourceSaver.save(self, SAVE_PATH)
static func load_profile_from_disk() -> PlayerKeymap:
	if ResourceLoader.exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH)
	return Data.keymaps[0]
