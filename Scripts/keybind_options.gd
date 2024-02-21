extends VBoxContainer
class_name KeybindsOptionsMenu

var keybind_entry_scene: PackedScene = load("res://Scenes/UI/keybind_entry.tscn")
var keybind_popup: PackedScene = load("res://Scenes/UI/keybind_popup.tscn")
var keybind_boxes: Array[KeybindEntry] = []
var key_event: InputEvent
var selected_entry: KeybindEntry
var listening_for_key: bool = false


func _ready() -> void:
	for index: int in Data.keymaps.size():
		var map: PlayerKeymap = Data.keymaps[index]
		var button: Button = Button.new()
		button.text = map.title
		button.pressed.connect(set_keymap.bind(index))
		$HBoxContainer.add_child(button)
	load_keybind_labels()


func set_keymap(keymap_index: int) -> void:
	Data.player_keymap = Data.keymaps[keymap_index]
	Data.player_keymap.apply()
	load_keybind_labels()


func load_keybind_labels() -> void:
	for box: KeybindEntry in keybind_boxes:
		box.queue_free()
	keybind_boxes.clear()
	for action: StringName in InputMap.get_actions():
		if !action.begins_with("ui_"):
			var entry: KeybindEntry = keybind_entry_scene.instantiate() as KeybindEntry
			entry.set_action_name(action)
			if InputMap.action_get_events(action).size() > 0:
				entry.set_primary_bind(InputMap.action_get_events(action)[0])
			if InputMap.action_get_events(action).size() > 1:
				entry.set_secondary_bind(InputMap.action_get_events(action)[1])
			keybind_boxes.append(entry)
			entry.primary_bind_pressed.connect(_on_primary_keybind_button_pressed.bind(entry))
			entry.secondary_bind_pressed.connect(_on_secondary_keybind_button_pressed.bind(entry))
			$ScrollContainer/VBoxContainer.add_child(entry)


func _on_primary_keybind_button_pressed(keybind_entry: KeybindEntry) -> void:
	selected_entry = keybind_entry
	var popup: Control = keybind_popup.instantiate()
	popup.event_detected.connect(change_primary_key)
	Game.UILayer.add_child(popup)


func _on_secondary_keybind_button_pressed(keybind_entry: KeybindEntry) -> void:
	selected_entry = keybind_entry
	var popup: Control = keybind_popup.instantiate()
	popup.event_detected.connect(change_secondary_key)
	Game.UILayer.add_child(popup)


func change_primary_key(event: InputEvent) -> void:
	Data.player_keymap.set_primary_action_event(selected_entry.action_string, event)
	selected_entry.set_primary_bind(event)


func change_secondary_key(event: InputEvent) -> void:
	Data.player_keymap.set_secondary_action_event(selected_entry.action_string, event)
	selected_entry.set_secondary_bind(event)
