class_name KeymapData extends RefCounted

var title: String = "default"
var map: Dictionary[String, Array]


func add_binding(bind_array: Array) -> void:
	var x: int = bind_array.size() - 1
	var arr: Array
	for i: int in x:
		arr.append(bind_array[i + 1])
	map[bind_array[0][0]] = arr


static func event_from_array(array: Array) -> InputEvent:
	if array.size() < 2:
		return null
	if array[0] == "InputEventKey":
		var event: InputEventKey = InputEventKey.new()
		event.physical_keycode = array[1]
		return event
	if array[0] == "InputEventMouseButton":
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.button_index = array[1]
		return event
	if array[0] == "InputEventJoypadButton":
		var event: InputEventJoypadButton = InputEventJoypadButton.new()
		event.button_index = array[1]
		return event
	return null


func apply() -> void:
	for action_string: String in map.keys():
		InputMap.action_erase_events(action_string)
		for binding: Array in map[action_string]:
			var event: InputEvent = event_from_array(binding)
			if event:
				InputMap.action_add_event(action_string, event)


func save_to_disc() -> void:
	var dir: DirAccess = DirAccess.open("user://")
	if !dir.dir_exists("keymaps"):
		dir.make_dir("keymaps")
	var save_file: FileAccess = FileAccess.open("user://keymaps/default", FileAccess.WRITE)
	var dict: Dictionary = {
		"title" = title,
		"map" = map,
	}
	var json_string: String = JSON.stringify(dict)
	save_file.store_line(json_string)


static func load_from_disk() -> KeymapData:
	if FileAccess.file_exists("user://keymaps/default"):
		var save_file: FileAccess = FileAccess.open("user://keymaps/default", FileAccess.READ)
		var json_string: String = save_file.get_line()
		var json: JSON = JSON.new()
		var parse_result: Error = json.parse(json_string)
		if parse_result == OK:
			var dict: Dictionary = json.data
			var keymap: KeymapData = KeymapData.new()
			keymap.title = dict["title"]
			for key: String in dict["map"].keys():
				keymap.map[key] = dict["map"][key]
			return keymap
	return KeymapData.new()
