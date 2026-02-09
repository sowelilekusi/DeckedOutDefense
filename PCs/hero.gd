class_name Hero
extends CharacterBody3D

signal ready_state_changed(state: bool)
signal placed_tower(tower: Tower)

@export var subviewport1: SubViewport
@export var subviewport2: SubViewport
@export var wave_preview_scene: PackedScene
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

@export var anim_tree: AnimationTree
@export var anim_tree2: AnimationTree
@export var weapon_pivot: Node3D
@export var cassette: Node3D
@export var left_hand_model: Node3D
@export var gauntlet_model: Node3D

var current_state: HeroState
var pre_fighting_state: HeroState
var hand_card_scene: PackedScene = preload("res://UI/card_hand.tscn")
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
var blank_cassettes: int = 0 :
	set(value):
		blank_cassettes = value
		hud.set_blank_cassette_count(value)
	get():
		return blank_cassettes
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
		return hand.item_at(hand_selected_index) if hand.size > 0 else null


@export var distance_between_steps: float = 2.2
var distance_travelled: float = 0.0
var foot_stepping: bool = false


func set_resolution(size: Vector2) -> void:
	$FirstPersonViewport.size = size
	$SubViewport.size = size


func set_zoom_factor(value: float) -> void:
	movement.zoom_factor = value


func _ready() -> void:
	Data.resolution_changed.connect(set_resolution)
	set_resolution(Vector2(1920, 1080) * Data.graphics.resolution_scaling)
	hud.disable_card_gameplay_ui()
	if game_manager:
		if game_manager.card_gameplay:
			hud.enable_card_gameplay_ui()
	
	if is_multiplayer_authority():
		ears.make_current()
		camera.make_current()
		sprite.queue_free()
		player_name_tag.queue_free()
		for card: Card in hero_class.deck:
			if game_manager and game_manager.card_gameplay:
				draw_pile.add(card)
			else:
				add_card(card)
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
	
	if is_on_floor() and $RayCast3D.is_colliding() and $RayCast3D.get_collider() is StaticBody3D:
		distance_travelled += get_real_velocity().length() * delta
		if distance_travelled >= distance_between_steps:
			var floor: StaticBody3D = $RayCast3D.get_collider()
			distance_travelled -= distance_between_steps
			if foot_stepping:
				if floor.is_in_group("grass"):
					$GrassFootSteps.play()
				if floor.is_in_group("dirt"):
					$DirtFootSteps.play()
				if floor.is_in_group("stone"):
					$StoneFootSteps.play()
				if floor.is_in_group("brick"):
					$BrickFootSteps.play()
			else:
				if floor.is_in_group("grass"):
					$GrassFootSteps2.play()
				if floor.is_in_group("dirt"):
					$DirtFootSteps2.play()
				if floor.is_in_group("stone"):
					$StoneFootSteps2.play()
				if floor.is_in_group("brick"):
					$BrickFootSteps2.play()
			foot_stepping = !foot_stepping


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
	if hand_selected_index >= hand.size:
		hand_selected_index = 0
	hud.hot_wheel.update_cassettes(get_wheel_cards())
	hud.show_features(selected_card)


func decrement_selected() -> void:
	if hand.size == 0:
		hand_selected_index = 0
		return
	hand_selected_index -= 1
	if hand_selected_index < 0:
		hand_selected_index = hand.size - 1
	hud.hot_wheel.update_cassettes(get_wheel_cards())
	hud.show_features(selected_card)


func get_wheel_cards() -> Array[Card]:
	var wheel_cards: Array[Card] = []
	if hand.size > 0:
		wheel_cards.append(hand.contents[hand_selected_index])
		var left_searches: int = floori((min(5, hand.size) - 1) / 2.0)
		var right_searches: int = ceili((min(5, hand.size) - 1) / 2.0)
		while left_searches > 0 or right_searches > 0:
			for x: int in left_searches:
				if hand_selected_index - (x + 1) >= 0:
					wheel_cards.append(hand.contents[hand_selected_index - (x + 1)])
					left_searches -= 1
				else:
					right_searches += left_searches
					left_searches = 0
			for x: int in right_searches:
				if hand_selected_index + (x + 1) < hand.size:
					wheel_cards.append(hand.contents[hand_selected_index + (x + 1)])
					right_searches -= 1
				else:
					left_searches += right_searches
					right_searches = 0
	return wheel_cards



func set_card_elements_visibility(value: bool) -> void:
	if value:
		hud.show_hot_wheel()
		hud.hot_wheel.update_cassettes(get_wheel_cards())
		hud.show_slots()
	else:
		hud.hide_hot_wheel()
		hud.hide_slots()


func _unhandled_input(event: InputEvent) -> void:
	if !is_multiplayer_authority() or paused:
		return
	if event.is_action_pressed("Pause"):
		var menu: PauseMenu = pause_menu_scene.instantiate() as PauseMenu
		pause()
		if game_manager:
			menu.game_manager = game_manager
			menu.quit_to_desktop_pressed.connect(game_manager.quit_to_desktop)
			menu.quit_to_main_menu_pressed.connect(game_manager.scene_switch_main_menu)
		menu.closed.connect(unpause)
		hud.add_child(menu)
	if event.is_action_pressed("Show Wave Preview"):
		var wave_preview: WaveViewer = wave_preview_scene.instantiate() as WaveViewer
		pause()
		hud.add_child(wave_preview)
		wave_preview.set_waves(game_manager.get_upcoming_waves(10), game_manager.wave)
		wave_preview.closed.connect(unpause)


func ready_self() -> void:
	edit_tool.interact_key_held = false
	if !ready_state:
		ready_state = true
		hud.shrink_wave_start_label()
		ready_audio.play()


func unready_self() -> void:
	if ready_state:
		ready_state = false
		hud.grow_wave_start_label()
		unready_audio.play()


func add_card(new_card: Card) -> void:
	hand.add(new_card)
	hud.pickup(new_card)
	place_card_audio.play()
	hud.hot_wheel.update_cassettes(get_wheel_cards())


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
		else:
			for x: int in discard_pile.size:
				draw_pile.add(discard_pile.remove_at(0))
				draw_pile.shuffle()
	hand_selected_index = 0


func equip_weapon(slot: int = 0) -> void:
	if weapons[slot] != null:
		unequip_weapon(slot)
		if hand.size == 1 or (!game_manager or !game_manager.card_gameplay):
			return
	if hand.size == 0:
		return
	var energy_cost: int = selected_card.cost
	if game_manager and game_manager.card_gameplay and energy < energy_cost:
		return
	if hand.size > 0:
		if game_manager and game_manager.card_gameplay:
			energy -= energy_cost
		place_card_audio.play()
		cards[slot] = hand.remove_at(hand.contents.find(selected_card))
		decrement_selected()
		hud.hot_wheel.update_cassettes(get_wheel_cards())
		#card_sprites[hand_selected_index].queue_free()
		#card_sprites.remove_at(hand_selected_index)
		if game_manager and game_manager.card_gameplay:
			discard_pile.add(cards[slot])
		#TODO: Alternate thing to do with the hand i guess
		#if !inventory.contents.has(cards[slot]):
		#decrement_selected()
		weapons[slot] = cards[slot].weapon_scene.instantiate()
		weapons[slot].stats = cards[slot].weapon_stats
		weapons[slot].name = str(weapons_spawn_count)
		weapons[slot].duration = 1
		weapons[slot].fired.connect(fighting_state.play_shoot_animation)
		weapons_spawn_count += 1
		weapons[slot].set_multiplayer_authority(multiplayer.get_unique_id())
		if slot == 0:
			hud.set_primary_button(cards[slot])
		else:
			hud.set_secondary_button(cards[slot])
		weapons[slot].set_hero(self)
		weapons[slot].visible = false
		weapon_pivot.add_child(weapons[slot])
		if slot == 0:
			weapons[slot].energy_changed.connect(hud.set_energy_pips)
			hud.energy_pips.max_energy = weapons[slot].max_energy


func stow_weapon(slot: int = 0) -> void:
	weapons[slot].release_trigger()
	weapons[slot].release_second_trigger()
	weapons[slot].visible = false
	weapons[slot].energy_changed.disconnect(hud.set_energy_pips)


func show_weapon(slot: int = 0) -> void:
	weapons[slot].release_trigger()
	weapons[slot].release_second_trigger()
	weapons[slot].energy_changed.connect(hud.set_energy_pips)
	hud.set_weapon_energy(int(weapons[slot].current_energy), weapons[slot].stats.energy_type)
	hud.energy_pips.max_energy = weapons[slot].max_energy


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
	if slot == 0:
		hud.set_primary_button(null)
	else:
		hud.set_secondary_button(null)
	weapons[slot].queue_free()
	weapons[slot] = null
	if !game_manager or !game_manager.card_gameplay:
		add_card(cards[slot])
	cards[slot] = null
	place_card_audio.play()
	hud.hot_wheel.update_cassettes(get_wheel_cards())


func _on_hitbox_took_damage(amount: int, damage_type: int, pos: Vector3) -> void:
	pass # Replace with function body.
