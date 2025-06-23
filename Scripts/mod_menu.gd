class_name ModMenu
extends PanelContainer

var entry_containers: Array[HBoxContainer]
var entry_names: Dictionary[String, Label]
var entry_boxes: Dictionary[String, CheckBox]

func _ready() -> void:
	for mod_name: String in Data.mods:
		var container: HBoxContainer = HBoxContainer.new()
		entry_containers.append(container)
		$VBoxContainer/ScrollContainer/VBoxContainer.add_child(container)
		var label: Label = Label.new()
		label.text = mod_name
		container.add_child(label)
		var box: CheckBox = CheckBox.new()
		box.button_pressed = false
		container.add_child(box)
		entry_names[mod_name] = label
		entry_boxes[mod_name] = box
	load_mod_list()


#TODO: make this remember preferences instead of always starting not loaded
#TODO: make this always load the base mod
func load_mod_list() -> void:
	var mod_list: Dictionary[String, bool] = {}
	for entry: String in entry_boxes:
		mod_list[entry] = entry_boxes[entry].button_pressed
	Data.load_mods(mod_list)
