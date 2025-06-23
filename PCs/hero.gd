class_name Hero
extends CharacterBody3D

signal ready_state_changed(state: bool)

@export var hero_class: HeroClass
@export var camera: Camera3D
@export var gun_camera: Camera3D
@export var left_hand_sprite: Sprite3D
@export var card_sprites: Array[CardInHand]
@export var left_hand: Node3D
@export var right_hand: Node3D
@export var right_hand_animator: AnimationPlayer
@export var edit_tool: PathEditTool
@export var gauntlet_sprite: Sprite3D
@export var sprite: EightDirectionSprite3D
@export var hand_sprite: Sprite2D
@export var interaction_raycast: RayCast3D
@export var inventory: Inventory
@export var gauntlet_cards: Array[CardInHand]
@export var pause_menu_scene: PackedScene
@export var hud: HUD
@export var movement: PlayerMovement
@export var sprint_zoom_speed: float = 0.2
@export var player_name_tag: Label
@export var weapon_swap_timer: Timer

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

var game_manager: GameManager
var hovering_item: InteractButton = null
var weapons_spawn_count: int = 0 #Used to prevent node name collisions for multiplayer
var inventory_selected_index: int = 0
var equipped_weapon: int = 0
var weapons: Array[Weapon] = [null, null]
var cards: Array[Card] = [null, null]
var weapons_active: bool = false
var paused: bool = false
var editing_mode: bool = true
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


func set_zoom_factor(value: float) -> void:
	movement.zoom_factor = value


func _ready() -> void:
	if is_multiplayer_authority():
		right_hand_animator.play("weapon_sway")
		right_hand_animator.speed_scale = 0
		ears.make_current()
		camera.make_current()
		sprite.queue_free()
		hand_sprite.texture = hero_class.hand_texture
		player_name_tag.queue_free()
		for card: Card in hero_class.deck:
			inventory.add(card)
	else:
		camera.set_visible(false)
		gun_camera.set_visible(false)
		hud.set_visible(false)
	if weapons[equipped_weapon] != null:
		weapons[equipped_weapon].set_raycast_origin(camera)
	sprite.texture.atlas = hero_class.texture
	check_left_hand_valid()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority() or paused:
		return
	if movement.input_vector == Vector2.ZERO:
		right_hand_animator.speed_scale = 0
	elif movement.sprinting:
		right_hand_animator.speed_scale = 1
	else:
		right_hand_animator.speed_scale = 0.6


func _process(delta: float) -> void:
	if !is_multiplayer_authority() or paused:
		return
	if !movement.sprinting:
		movement.zoom_factor += sprint_zoom_speed * 2.0 * delta
		if movement.zoom_factor > 1.0:
			movement.zoom_factor = 1.0
	
	if editing_mode:
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
		
		if is_instance_valid(edit_tool.ray_collider) and edit_tool.ray_collider is TowerBase:
			card_sprites[0].view_tower()
		else:
			card_sprites[0].view_weapon()
		if Input.is_action_just_pressed("Interact"):
			edit_tool.interact()
			if interaction_raycast.get_collider() is InteractButton:
				var button: InteractButton = interaction_raycast.get_collider() as InteractButton
				if currency >= button.press_cost:
					button.press(self)
					currency -= button.press_cost
			if interaction_raycast.get_collider() is ItemCard:
				add_card(interaction_raycast.get_collider().pick_up())
		#if Input.is_action_just_pressed("Equip In Gauntlet"):
		#	equip_weapon()
		#if Input.is_action_just_pressed("Secondary Fire"):
		#	if equipped_card or offhand_card:
		#		swap_weapons()
		if Input.is_action_just_pressed("Equip Primary Weapon"):
			if weapons[0]:
				unequip_weapon(0)
			else:
				equip_weapon(0)
		if Input.is_action_just_pressed("Equip Secondary Weapon"):
			if weapons[1]:
				unequip_weapon(1)
			else:
				equip_weapon(1)
		if Input.is_action_just_pressed("Select Next Card") and inventory.contents.size() > 1:
			increment_selected()
			swap_card_audio.play()
		if Input.is_action_just_pressed("Select Previous Card") and inventory.contents.size() > 1:
			decrement_selected()
			swap_card_audio.play()
		if Input.is_action_just_pressed("Primary Fire"):
			edit_tool.interact_key_held = true
		if Input.is_action_just_released("Primary Fire"):
			edit_tool.interact_key_held = false
		if weapons[equipped_weapon] != null:
			weapons[equipped_weapon].release_trigger()
			weapons[equipped_weapon].release_second_trigger()
	else:
		if weapons[equipped_weapon] and weapons_active:
			if Input.is_action_just_pressed("Primary Fire"):
				weapons[equipped_weapon].hold_trigger()
			if Input.is_action_just_released("Primary Fire"):
				weapons[equipped_weapon].release_trigger()
			if Input.is_action_pressed("Secondary Fire"):
				weapons[equipped_weapon].hold_second_trigger()
			if Input.is_action_just_released("Secondary Fire"):
				weapons[equipped_weapon].release_second_trigger()
			if Input.is_action_pressed("Primary Fire"):
				movement.can_sprint = false
			if Input.is_action_pressed("Secondary Fire"):
				movement.can_sprint = false
		if Input.is_action_just_pressed("Equip Primary Weapon"):
			if equipped_weapon == 1 and weapons[0]:
				swap_weapons()
		if Input.is_action_just_pressed("Equip Secondary Weapon"):
			if equipped_weapon == 0 and weapons[1]:
				swap_weapons()
		if Input.is_action_just_pressed("Swap Weapons"):
			swap_weapons()
	
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
	check_left_hand_valid()


func increment_selected() -> void:
	inventory_selected_index += 1
	if inventory_selected_index >= inventory.contents.keys().size():
		inventory_selected_index = 0


func decrement_selected() -> void:
	inventory_selected_index -= 1
	if inventory_selected_index < 0:
		inventory_selected_index = max(inventory.contents.keys().size() - 1, 0)


func _unhandled_input(event: InputEvent) -> void:
	if !is_multiplayer_authority() or paused:
		return
	if editing_mode and event.is_action_pressed("Ready"):
		if ready_state:
			unready_self()
		else:
			ready_self()
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
		#if !equipped_card:
		#	hud.place_icon.set_visible(true)
		#if !offhand_card:
		#	hud.swap_icon.set_visible(true)
		hud.grow_wave_start_label()
		unready_audio.play()
		networked_set_ready_state(ready_state)


func add_card(new_card: Card) -> void:
	inventory.add(new_card)
	hud.pickup(new_card)
	place_card_audio.play()


func unpause() -> void:
	paused = false
	movement.paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func pause() -> void:
	paused = true
	movement.paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func enter_editing_mode(value: int) -> void:
	gauntlet_sprite.visible = true
	weapons_active = false
	hud.set_wave_count(value + 1)
	hud.set_energy_visible(false)
	hud.grow_wave_start_label()
	editing_mode = true
	edit_tool.enabled = true
	left_hand.visible = true
	if weapons[equipped_weapon]:
		weapons[equipped_weapon].release_trigger()
		weapons[equipped_weapon].visible = false


func exit_editing_mode(value: int) -> void:
	gauntlet_sprite.visible = false
	weapons_active = false
	hud.set_wave_count(value)
	#if !weapon and offhand_weapon:
	#	swap_weapons()
	var offhand_weapon: Weapon = weapons[0] if equipped_weapon == 1 else weapons[1]
	if offhand_weapon:
		offhand_weapon.current_energy = offhand_weapon.max_energy
		#offhand_weapon.energy_changed.emit(offhand_weapon.current_energy)
	if (!weapons[equipped_weapon] and offhand_weapon) or (weapons[0] and equipped_weapon == 1):
		swap_weapons()
	if weapons[equipped_weapon]:
		hud.set_energy_visible(true)
		#weapon.set_visible(false)
		weapons[equipped_weapon].current_energy = weapons[equipped_weapon].max_energy
		#this had to be commented out coz the new energy bar thinks "energy changed" is "energy used"
		#weapons[equipped_weapon].energy_changed.emit(weapons[equipped_weapon].current_energy)
	edit_tool.enabled = false
	edit_tool.delete_tower_preview()
	left_hand.visible = false
	hud.unset_hover_text()
	editing_mode = false
	weapon_swap_timer.start()


func check_left_hand_valid() -> void:
	if !editing_mode:
		return
	if inventory.size == 0:
		left_hand_sprite.visible = false
		#gauntlet.texture.region = Rect2(64, 0, 64, 64)
	else:
		left_hand_sprite.visible = true
		#gauntlet.texture.region = Rect2(0, 0, 64, 64)
		var selected_card: Card = inventory.contents.keys()[inventory_selected_index]
		for index: int in card_sprites.size():
			if index < inventory.contents[selected_card]:
				card_sprites[index].visible = true
				card_sprites[index].set_card(selected_card)
				#card_sprites[index].view_weapon()
			else:
				card_sprites[index].visible = false


func equip_weapon(slot: int = 0) -> void:
	if weapons[slot] != null:
		unequip_weapon()
		return
	if inventory.size > 0:
		place_card_audio.play()
		cards[slot] = inventory.remove_at(inventory_selected_index)
		if !inventory.contents.has(cards[slot]):
			decrement_selected()
		weapons[slot] = cards[slot].weapon_scene.instantiate()
		weapons[slot].name = str(weapons_spawn_count)
		networked_equip_weapon.rpc(Data.cards.find(cards[slot]), 0, weapons_spawn_count)
		weapons_spawn_count += 1
		#weapons[slot].energy_changed.connect(hud.set_weapon_energy.bind(weapons[slot].stats.energy_type))
		weapons[slot].set_multiplayer_authority(multiplayer.get_unique_id())
		gauntlet_cards[slot].set_card(cards[slot])
		if slot == 0:
			hud.place_icon.visible = false
		else:
			hud.swap_icon.visible = false
		gauntlet_cards[slot].view_weapon()
		gauntlet_cards[slot].visible = true
		weapons[slot].set_hero(self)
		weapons[slot].visible = false
		right_hand.add_child(weapons[slot])
		check_left_hand_valid()
		if slot == 0:
			weapons[slot].energy_spent.connect(hud.new_energy_bar.use_energy)
			weapons[slot].energy_recharged.connect(hud.new_energy_bar.gain_energy)
			hud.new_energy_bar.max_energy = weapons[slot].max_energy
			if weapons[slot].stats.energy_type == Data.EnergyType.CONTINUOUS:
				hud.new_energy_bar.enable_progress_bar()
			if weapons[slot].stats.energy_type == Data.EnergyType.DISCRETE:
				hud.new_energy_bar.create_discrete_icons(weapons[slot].max_energy)
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
	hud.set_weapon_energy(weapons[slot].current_energy, weapons[slot].stats.energy_type)
	hud.new_energy_bar.max_energy = weapons[slot].max_energy
	if weapons[slot].stats.energy_type == Data.EnergyType.CONTINUOUS:
		hud.new_energy_bar.enable_progress_bar()
	if weapons[slot].stats.energy_type == Data.EnergyType.DISCRETE:
		hud.new_energy_bar.create_discrete_icons(weapons[slot].max_energy)
	hud.new_energy_bar.use_energy(weapons[slot].max_energy - weapons[slot].current_energy, weapons[slot].stats.energy_type)
	var offhand: int = 0 if equipped_weapon == 1 else 1
	if !weapons[offhand]:
		hud.new_energy_bar.disable_secondary_energy()


func swap_weapons() -> void:
	if !weapons[0] and !weapons[1]:
		return
	weapons_active = false
	swap_off_audio.play()
	hud.audio_guard = true
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
	#gauntlet_sprite.set_visible(true)
	weapons[slot].queue_free()
	weapons[slot] = null
	inventory.add(cards[slot])
	cards[slot] = null
	place_card_audio.play()
	check_left_hand_valid()


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
