class_name CharacterSelect extends Node3D

signal hero_selected(hero_class: int)
signal hero_confirmed()

@export var hero_preview_panel: CharacterPreview

var podiums: Array[CharacterPodium]

var character_selected: int = 0
var can_hit_button: bool = true

func _ready() -> void:
	hero_preview_panel.set_preview(Data.characters[0])
	var heroes: int = Data.characters.size()
	var x: int = 0
	for hero: HeroClass in Data.characters:
		var pivot: Node3D = Node3D.new()
		$Podiums.add_child(pivot)
		var podium: CharacterPodium = hero.podium.instantiate() as CharacterPodium
		podium.position = Vector3(0.0, -0.5, 5.0)
		podiums.append(podium)
		pivot.add_child(podium)
		pivot.rotate_y((TAU / heroes) * x)
		x += 1
	podiums[0].show_content()
	if Data.save_data.mage_unlocked:
		podiums[1].show_content()


func reset_button() -> void:
	can_hit_button = true


func setup_ui() -> void:
	#TODO: This should all tie into a proper achievements system
	if character_selected == 0 or (character_selected == 1 and Data.save_data.mage_unlocked):
		$VBoxContainer/Button.disabled = false
		hero_preview_panel.set_preview(Data.characters[character_selected])
		hero_selected.emit(character_selected)
	elif character_selected == 1 and !Data.save_data.mage_unlocked and Data.save_data.mage_card_seen_in_shop:
		hero_preview_panel.setup_with_basic_text(Data.characters[character_selected], "Buy " + str(Data.save_data.mage_cards_bought) + "/10 scrolls in the shop to unlock")
	else:
		$VBoxContainer/Button.disabled = true
		hero_preview_panel.setup_with_basic_text(Data.characters[character_selected], podiums[character_selected].text)


func retreat_selector() -> void:
	if !can_hit_button:
		return
	can_hit_button = false
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Node3D, "rotation_degrees", Vector3(0.0, $Node3D.rotation_degrees.y - 90.0, 0.0), 1.0)
	tween.tween_callback(reset_button)
	character_selected -= 1
	if character_selected < 0:
		character_selected = Data.characters.size() - 1
	setup_ui()


func advance_selector() -> void:
	if !can_hit_button:
		return
	can_hit_button = false
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Node3D, "rotation_degrees", Vector3(0.0, $Node3D.rotation_degrees.y + 90.0, 0.0), 1.0)
	tween.tween_callback(reset_button)
	character_selected += 1
	if character_selected >= Data.characters.size():
		character_selected = 0
	setup_ui()


func _on_confirm_button_pressed() -> void:
	hero_confirmed.emit()
