class_name Hero
extends CharacterBody3D

signal ready_state_changed(state: bool)

@export var hero_class: HeroClass
@export var camera: Camera3D
@export var gun_camera: Camera3D
@export var left_hand: Node3D
@export var right_hand: Node3D
@export var edit_tool: PathEditTool
@export var carding_tool: CardPlacingTool
@export var sprite: EightDirectionSprite3D
@export var interaction_raycast: RayCast3D
@export var draw_pile: Inventory
@export var hand: Inventory
@export var discard_pile: Inventory
@export var gauntlet_cards: Array[CardInHand]
@export var pause_menu_scene: PackedScene
@export var hud: HUD
@export var movement: PlayerMovement
@export var sprint_zoom_speed: float = 0.2
@export var player_name_tag: Label
@export var weapon_swap_timer: Timer
@export var card3d_scene: PackedScene
@export var card_select_scene: PackedScene
@export var editing_states: Array[HeroState]
@export var fighting_state: HeroState
@export var default_state: HeroState

@export_subgroup("Audio")
@export var ears: AudioListener3D
@export var place_card_audio: AudioStreamPlayer
@export var swap_card_audio: AudioStreamPlayer
@export var ready_audio: AudioStreamPlayer
@export var unready_audio: AudioStreamPlayer
@export var fullpower_audio: AudioStreamPlayer
@export var zeropower_audio: AudioStreamPlayer
@export var swap_off_audio: AudioStreamPlayer
@export var swap_on_audio: AudioStreamPlayer

var current_state: HeroState
var pre_fighting_state: HeroState
var selection_boxes: Array[CardSelectionBox] = []
var unique_cards: Array[Card] = []
var hand_card_scene: PackedScene = preload("res://Scenes/UI/card_hand.tscn")
var card_sprites: Array[CardInHand]
var game_manager: GameManager
var hovering_item: InteractButton = null
var weapons_spawn_count: int = 0 #Used to prevent node name collisions for multiplayer
var hand_selected_index: int = 0
var equipped_weapon: int = 0
var weapons: Array[Weapon] = [null, null]
var cards: Array[Card] = [null, null]
var weapons_active: bool = false
var paused: bool = false
var profile: PlayerProfile
var ready_state: bool = false : 
	set(value):
		ready_state = value
		ready_state_changed.emit(value)
var currency: int = 0 : 
	set(value):
		currency = value
		hud.set_currency_count(value)
	get:
		return currency
var energy: int = 0 :
	set(value):
		energy = value
		hud.set_energy_amount(value)
	get:
		return energy
var selected_card: Card :
	set(_value):
		pass
	get():
		return unique_cards[hand_selected_index]


func set_zoom_factor(value: float) -> void:
	movement.zoom_factor = value


func _ready() -> void:
	if is_multiplayer_authority():
		ears.make_current()
		camera.make_current()
		sprite.queue_free()
		player_name_tag.queue_free()
		for card: Card in hero_class.deck:
			draw_pile.add(card)
	else:
		camera.set_visible(false)
		gun_camera.set_visible(false)
		hud.set_visible(false)
	
	for state: HeroState in editing_states:
		state.state_changed.connect(update_state)
	fighting_state.state_changed.connect(update_state)
	current_state = default_state
	current_state.enter_state()
	
	if weapons[equipped_weapon] != null:
		weapons[equipped_weapon].set_raycast_origin(camera)
	sprite.texture.atlas = hero_class.texture
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func update_state(new_state: HeroState) -> void:
	current_state.exit_state()
	current_state = new_state
	current_state.enter_state()


func enter_fighting_state() -> void:
	pre_fighting_state = current_state
	update_state(fighting_state)


func exit_fighting_state() -> void:
	update_state(pre_fighting_state)


func add_selection(card: Card) -> void:
	if !unique_cards.has(card):
		unique_cards.append(card)
		var box: CardSelectionBox = card_select_scene.instantiate()
		box.set_card(card)
		box.set_key(unique_cards.size() - 1)
		selection_boxes.append(box)
		$HUD/selection_boxes.add_child(box)


func check_removal() -> void:
	var index: int = -1
	for card: Card in unique_cards:
		if !hand.contents.has(card):
			index = unique_cards.find(card)
	if index >= 0:
		unique_cards.remove_at(index)
		selection_boxes[index].queue_free()
		selection_boxes.remove_at(index)
		if selection_boxes.size() > 0:
			for i: int in selection_boxes.size():
				var card: Card = unique_cards[i]
				selection_boxes[i].set_card(card)
				selection_boxes[i].set_key(i)
			if hand_selected_index == index:
				decrement_selected()
			update_selected_box()


func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority() or paused:
		return


func _process(delta: float) -> void:
	if !is_multiplayer_authority() or paused:
		return
	if !movement.sprinting:
		movement.zoom_factor += sprint_zoom_speed * 2.0 * delta
		if movement.zoom_factor > 1.0:
			movement.zoom_factor = 1.0
	
	current_state.process_state(delta)
	
	if movement.sprinting:
		movement.zoom_factor -= sprint_zoom_speed * delta
		if movement.zoom_factor <= 1.0 - movement.sprint_zoom_factor:
			movement.zoom_factor = 1.0 - movement.sprint_zoom_factor
	camera.fov = Data.graphics.hfov * (1.0 / movement.zoom_factor)
	
	if Input.is_action_just_pressed("View Map"):
		hud.maximise_minimap()
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_released("View Map"):
		hud.minimize_minimap()
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func check_world_button() -> void:
	if interaction_raycast.is_colliding() and interaction_raycast.get_collider() is InteractButton:
		hud.set_hover_text(interaction_raycast.get_collider().hover_text)
		if !hovering_item or hovering_item != interaction_raycast.get_collider():
			if hovering_item:
				hovering_item.disable_hover_effect()
			hovering_item = interaction_raycast.get_collider()
			hovering_item.enable_hover_effect()
	else:
		hud.unset_hover_text()
		if hovering_item:
			hovering_item.disable_hover_effect()
			hovering_item = null
	
	if Input.is_action_just_pressed("Interact"):
		if interaction_raycast.get_collider() is InteractButton:
			var button: InteractButton = interaction_raycast.get_collider() as InteractButton
			button.press(self)
		if interaction_raycast.get_collider() is ItemCard:
			add_card(interaction_raycast.get_collider().pick_up())


func increment_selected() -> void:
	hand_selected_index += 1
	if hand_selected_index >= unique_cards.size():
		hand_selected_index = 0
	update_selected_box()


func decrement_selected() -> void:
	if unique_cards.size() == 0:
		hand_selected_index = 0
		return
	hand_selected_index -= 1
	if hand_selected_index < 0:
		hand_selected_index = unique_cards.size() - 1
	update_selected_box()


func set_card_elements_visibility(value: bool) -> void:
	$FirstPersonViewport/Head2/LeftHand.visible = value
	$HUD/selection_boxes.visible = value
	$HUD/PlaceIcon.visible = value
	$HUD/SwapIcon.visible = value
	if cards[0]:
		$HUD/PlaceIcon.visible = false
	if cards[1]:
		$HUD/SwapIcon.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if !is_multiplayer_authority() or paused:
		return
	if event.is_action_pressed("Pause"):
		var menu: PauseMenu = pause_menu_scene.instantiate() as PauseMenu
		pause()
		menu.game_manager = game_manager
		menu.quit_to_desktop_pressed.connect(game_manager.quit_to_desktop)
		menu.quit_to_main_menu_pressed.connect(game_manager.scene_switch_main_menu)
		menu.closed.connect(unpause)
		hud.add_child(menu)


func ready_self() -> void:
	edit_tool.interact_key_held = false
	if !ready_state:
		ready_state = true
		hud.place_icon.set_visible(false)
		hud.swap_icon.set_visible(false)
		hud.shrink_wave_start_label()
		ready_audio.play()
		networked_set_ready_state.rpc(ready_state)


func unready_self() -> void:
	if ready_state:
		ready_state = false
		hud.grow_wave_start_label()
		unready_audio.play()
		networked_set_ready_state(ready_state)


func add_card(new_card: Card) -> void:
	hand.add(new_card)
	hud.pickup(new_card)
	place_card_audio.play()
	add_selection(new_card)


func unpause() -> void:
	paused = false
	movement.paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func pause() -> void:
	paused = true
	movement.paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func iterate_duration() -> void:
	for slot: int in weapons.size():
		if weapons[slot] == null:
			continue
		weapons[slot].duration -= 1
		if slot == 0:
			hud.primary_duration.text = "primary weapon rounds left = " + str(weapons[slot].duration)
		elif slot == 1:
			hud.secondary_duration.text = "secondary weapon rounds left = " + str(weapons[slot].duration)
		if weapons[slot].duration <= 0:
			unequip_weapon(slot)


func draw_to_hand_size() -> void:
	var hand_size: int = 5
	while hand.size < hand_size:
		if draw_pile.size == 0 and discard_pile.size == 0:
			return
		if draw_pile.size > 0:
			var card: Card = draw_pile.remove_at(0)
			hand.add(card)
			var display: Card3D = card3d_scene.instantiate()
			display.set_card(card)
			display.position = Vector3(0.01 * hand.size, 0.0, -0.001 * hand.size)
			display.rotation_degrees = Vector3(0.0, 0.0, -10.0 * hand.size)
			$FirstPersonViewport/Head2/LeftHand/Cards.add_child(display)
			#var tween: Tween = create_tween()
			#tween.set_ease(Tween.EASE_OUT)
			#tween.set_trans(Tween.TRANS_CUBIC)
			#tween.tween_property(display, "position", Vector2(200.0 * hand.size, 80.0), 0.5)
		else:
			for x: int in discard_pile.size:
				draw_pile.add(discard_pile.remove_at(0))
				draw_pile.shuffle()
	unique_cards = []
	selection_boxes = []
	for card: Card in hand.contents:
		if !unique_cards.has(card):
			unique_cards.append(card)
	for i: int in $HUD/selection_boxes.get_child_count():
		$HUD/selection_boxes.get_child(i).queue_free()
	for i: int in unique_cards.size():
		var card: Card = unique_cards[i]
		var box: CardSelectionBox = card_select_scene.instantiate()
		box.set_card(card)
		box.set_key(i)
		selection_boxes.append(box)
		$HUD/selection_boxes.add_child(box)
	hand_selected_index = 0
	update_selected_box()


func update_selected_box() -> void:
	for box: CardSelectionBox in selection_boxes:
		box.deselect()
	selection_boxes[hand_selected_index].select()


func equip_weapon(slot: int = 0) -> void:
	if hand.size == 0:
		return
	var energy_cost: int = int(hand.item_at(hand_selected_index).rarity) + 1
	energy_cost *= 2
	if energy < energy_cost:
		return
	if weapons[slot] != null:
		unequip_weapon(slot)
	if hand.size > 0:
		energy -= energy_cost
		place_card_audio.play()
		cards[slot] = hand.remove_at(hand.contents.find(selected_card))
		#card_sprites[hand_selected_index].queue_free()
		#card_sprites.remove_at(hand_selected_index)
		discard_pile.add(cards[slot])
		#TODO: Alternate thing to do with the hand i guess
		#if !inventory.contents.has(cards[slot]):
		#decrement_selected()
		weapons[slot] = cards[slot].weapon_scene.instantiate()
		weapons[slot].name = str(weapons_spawn_count)
		weapons[slot].duration = cards[slot].duration
		networked_equip_weapon.rpc(Data.cards.find(cards[slot]), 0, weapons_spawn_count)
		weapons_spawn_count += 1
		weapons[slot].set_multiplayer_authority(multiplayer.get_unique_id())
		gauntlet_cards[slot].set_card(cards[slot])
		if slot == 0:
			hud.primary_duration.text = "primary weapon rounds left = " + str(weapons[slot].duration)
		elif slot == 1:
			hud.secondary_duration.text = "secondary weapon rounds left = " + str(weapons[slot].duration)
		if slot == 0:
			hud.place_icon.visible = false
		else:
			hud.swap_icon.visible = false
		gauntlet_cards[slot].view_weapon()
		gauntlet_cards[slot].visible = true
		weapons[slot].set_hero(self)
		weapons[slot].visible = false
		right_hand.add_child(weapons[slot])
		check_removal()
		if slot == 0:
			weapons[slot].energy_spent.connect(hud.new_energy_bar.use_energy)
			weapons[slot].energy_recharged.connect(hud.new_energy_bar.gain_energy)
			hud.new_energy_bar.max_energy = weapons[slot].max_energy
			if weapons[slot].stats.energy_type == Data.EnergyType.CONTINUOUS:
				hud.new_energy_bar.enable_progress_bar()
			if weapons[slot].stats.energy_type == Data.EnergyType.DISCRETE:
				hud.new_energy_bar.create_discrete_icons(int(weapons[slot].max_energy))
		else:
			weapons[slot].energy_recharged.connect(hud.new_energy_bar.gain_secondary_energy)
			hud.new_energy_bar.secondary_max_energy = weapons[slot].max_energy
			hud.new_energy_bar.secondary_energy = weapons[slot].current_energy


func stow_weapon(slot: int = 0) -> void:
	weapons[slot].release_trigger()
	weapons[slot].release_second_trigger()
	weapons[slot].visible = false
	weapons[slot].energy_spent.disconnect(hud.new_energy_bar.use_energy)
	weapons[slot].energy_recharged.disconnect(hud.new_energy_bar.gain_energy)
	weapons[slot].energy_recharged.connect(hud.new_energy_bar.gain_secondary_energy)
	hud.new_energy_bar.secondary_max_energy = weapons[slot].max_energy
	hud.new_energy_bar.secondary_energy = weapons[slot].current_energy


func show_weapon(slot: int = 0) -> void:
	weapons[slot].release_trigger()
	weapons[slot].release_second_trigger()
	weapons[slot].energy_recharged.disconnect(hud.new_energy_bar.gain_secondary_energy)
	weapons[slot].energy_spent.connect(hud.new_energy_bar.use_energy)
	weapons[slot].energy_recharged.connect(hud.new_energy_bar.gain_energy)
	hud.set_weapon_energy(int(weapons[slot].current_energy), weapons[slot].stats.energy_type)
	hud.new_energy_bar.max_energy = weapons[slot].max_energy
	if weapons[slot].stats.energy_type == Data.EnergyType.CONTINUOUS:
		hud.new_energy_bar.enable_progress_bar()
	if weapons[slot].stats.energy_type == Data.EnergyType.DISCRETE:
		hud.new_energy_bar.create_discrete_icons(int(weapons[slot].max_energy))
	hud.new_energy_bar.use_energy(weapons[slot].max_energy - weapons[slot].current_energy, weapons[slot].stats.energy_type)
	var offhand: int = 0 if equipped_weapon == 1 else 1
	if !weapons[offhand]:
		hud.new_energy_bar.disable_secondary_energy()


func swap_weapons() -> void:
	if !weapons[0] and !weapons[1]:
		return
	weapons_active = false
	swap_off_audio.play()
	if weapons[equipped_weapon]:
		stow_weapon(equipped_weapon)
	equipped_weapon = 0 if equipped_weapon == 1 else 1
	show_weapon(equipped_weapon)
	weapon_swap_timer.start()


func _on_timer_timeout() -> void:
	weapons_active = true
	if weapons[equipped_weapon]:
		swap_on_audio.play()
		weapons[equipped_weapon].visible = true


func unequip_weapon(slot: int = 0) -> void:
	networked_unequip_weapon.rpc(slot)
	gauntlet_cards[slot].visible = false
	if slot == 0:
		hud.place_icon.visible = true
		hud.new_energy_bar.blank()
	else:
		hud.swap_icon.visible = true
		hud.new_energy_bar.disable_secondary_energy()
	weapons[slot].queue_free()
	weapons[slot] = null
	cards[slot] = null
	place_card_audio.play()


#MULTIPLAYER NETWORKED FUNCTIONS
@rpc("reliable")
func networked_set_ready_state(state: bool) -> void:
	ready_state = state


@rpc("reliable")
func networked_swap_weapon() -> void:
	swap_weapons()


@rpc("reliable")
func networked_equip_weapon(card_index: int, slot: int, id: int) -> void:
	var new_card: Card = Data.cards[card_index]
	var new_weapon: Weapon = new_card.weapon_scene.instantiate()
	new_weapon.set_multiplayer_authority(multiplayer.get_remote_sender_id())
	new_weapon.name = str(id)
	new_weapon.set_hero(self)
	right_hand.add_child(new_weapon)
	cards[slot] = new_card
	weapons[slot] = new_weapon


@rpc("reliable")
func networked_unequip_weapon(slot: int) -> void:
	weapons[slot].queue_free()
	weapons[slot] = null
	cards[slot] = null
