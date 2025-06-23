extends VBoxContainer
class_name KeybindsOptionsMenu

var keybind_entry_scene: PackedScene = load("res://Scenes/UI/keybind_entry.tscn")
var keybind_popup: PackedScene = load("res://Scenes/UI/keybind_popup.tscn")
var keybind_boxes: Array[KeybindEntry] = []
var key_event: InputEvent
var selected_entry: KeybindEntry
var listening_for_key: bool = false
var ui_layer: CanvasLayer


func _ready() -> void:
	#for index: int in Data.keymaps.size():
	#	var map: PlayerKeymap = Data.keymaps[index]
	#	var button: Button = Button.new()
	#	button.text = map.title
	#	button.pressed.connect(set_keymap.bind(index))
	#	$HBoxContainer.add_child(button)
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
				for event: InputEvent in InputMap.action_get_events(action):
					entry.add_bind_button(event)
			keybind_boxes.append(entry)
			entry.bind_button_pressed.connect(_on_keybind_button_pressed.bind(entry))
			$ScrollContainer/VBoxContainer.add_child(entry)


func _on_keybind_button_pressed(button: Button, keybind_entry: KeybindEntry) -> void:
	var popup: KeybindPopup = keybind_popup.instantiate()
	popup.event_detected.connect(keybind_entry.set_button_bind.bind(button))
	ui_layer.add_child(popup)


func save() -> void:
	for entry: KeybindEntry in keybind_boxes:
		Data.keymap_data.add_binding(entry.to_array())
